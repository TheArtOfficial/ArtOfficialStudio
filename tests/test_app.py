import unittest
import os
import sys
import json
from unittest.mock import patch, MagicMock
from flask import Flask, url_for
from flask.testing import FlaskClient

# Add the parent directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from control_panel.app import app, db

class TestFlaskApp(unittest.TestCase):
    def setUp(self):
        # Configure app for testing
        app.config['TESTING'] = True
        app.config['WTF_CSRF_ENABLED'] = False
        self.app = app.test_client()
        self.app_context = app.app_context()
        self.app_context.push()

    def tearDown(self):
        self.app_context.pop()

    def test_index_route(self):
        # Test the index route
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Control Panel', response.data)

    def test_login_route(self):
        # Test login route
        response = self.app.get('/login')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Login', response.data)

    @patch('control_panel.app.User')
    def test_login_post(self, mock_user):
        # Test login POST request
        mock_user.query.filter_by.return_value.first.return_value = MagicMock(
            check_password=lambda x: True
        )
        
        response = self.app.post('/login', data={
            'username': 'test_user',
            'password': 'test_password'
        }, follow_redirects=True)
        
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Dashboard', response.data)

    def test_logout_route(self):
        # Test logout route
        with self.app.session_transaction() as sess:
            sess['user_id'] = 1
        
        response = self.app.get('/logout', follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Login', response.data)

    @patch('control_panel.app.current_user')
    def test_dashboard_route(self, mock_current_user):
        # Test dashboard route
        mock_current_user.is_authenticated = True
        
        response = self.app.get('/dashboard')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Dashboard', response.data)

    def test_api_status(self):
        # Test API status endpoint
        response = self.app.get('/api/status')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIn('status', data)

    @patch('control_panel.app.Docker')
    def test_docker_operations(self, mock_docker):
        # Test Docker operations
        mock_docker.return_value.containers.list.return_value = []
        
        response = self.app.get('/api/docker/containers')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIsInstance(data, list)

    def test_error_handling(self):
        # Test error handling
        response = self.app.get('/nonexistent-route')
        self.assertEqual(response.status_code, 404)

    @patch('control_panel.app.request')
    def test_file_upload(self, mock_request):
        # Test file upload
        mock_file = MagicMock()
        mock_file.filename = 'test.txt'
        mock_request.files = {'file': mock_file}
        
        response = self.app.post('/upload', data={
            'file': (mock_file, 'test.txt')
        })
        self.assertEqual(response.status_code, 200)

    def test_session_management(self):
        # Test session management
        with self.app.session_transaction() as sess:
            sess['user_id'] = 1
            self.assertEqual(sess['user_id'], 1)

    @patch('control_panel.app.send_file')
    def test_file_download(self, mock_send_file):
        # Test file download
        mock_send_file.return_value = MagicMock(status_code=200)
        
        response = self.app.get('/download/test.txt')
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main() 