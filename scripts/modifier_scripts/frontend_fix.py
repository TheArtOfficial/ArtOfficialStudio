import argparse
import os

def adjust_comfyUI(python_cmd, comfyui_path):
    # server.py
    subpath_service_worker = 'subpath_service_worker.js'
    db_op = '''
const STORE_NAME = 'paths';

function openDB() {
    return new Promise((resolve, reject) => {
        const DB_NAME = 'registeredPathsDB';
        const DB_VERSION = 1;
        const request = indexedDB.open(DB_NAME, DB_VERSION);

        request.onupgradeneeded = (event) => {
            const db = event.target.result;
            if (!db.objectStoreNames.contains(STORE_NAME)) {
                db.createObjectStore(STORE_NAME, { keyPath: 'pathValue' });
            }
        };

        request.onsuccess = (event) => {
            resolve(event.target.result);
        };

        request.onerror = (event) => {
            self.console.error('IndexedDB 打开失败:', event.target.error);
            reject(event.target.error);
        };
    });
}

// 添加路径到数据库
async function addPathToDB(path) {
    let db = null;
    try {
        db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction(STORE_NAME, 'readwrite');
            const store = transaction.objectStore(STORE_NAME);

            // 直接尝试获取特定路径
            const getRequest = store.get(path);

            getRequest.onsuccess = () => {
                if (!getRequest.result) {
                    // 路径不存在，添加它
                    const addRequest = store.put({ pathValue: path });
                    addRequest.onsuccess = () => resolve(true);
                    addRequest.onerror = (e) => {
                        self.console.error('添加路径失败:', e.target.error);
                        reject(e.target.error);
                    };
                } else {
                    resolve(false); // 路径已存在
                }
            };

            getRequest.onerror = (e) => {
                self.console.error('获取路径失败:', e.target.error);
                reject(e.target.error);
            };
        });
    } catch (error) {
        self.console.error('添加路径到数据库时出错:', error);
        throw error;
    } finally {
        // 确保数据库连接始终关闭
        if (db) db.close();
    }
}

async function loadPathsFromDB() {
    let db = null;
    try {
        db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction(STORE_NAME, 'readonly');
            const store = transaction.objectStore(STORE_NAME);

            const request = store.getAll();

            request.onsuccess = () => {
                const items = request.result;
                const paths = new Set();
                items.forEach(item => paths.add(item.pathValue));
                resolve(paths);
            };

            request.onerror = (e) => {
                self.console.error('获取路径失败:', e.target.error);
                reject(e.target.error);
            };
        });
    } catch (error) {
        self.console.error('从数据库加载路径时出错:', error);
        throw error;
    } finally {
        // 确保数据库连接始终关闭
        if (db) db.close();
    }
}
'''
    subpath_service_worker_script = f'''<script>
{db_op}
const subpath_service_worker = "{subpath_service_worker}"''' + '''
let url = new URL(location.href);
let subpath = url.pathname.slice(0, url.pathname.lastIndexOf('/') + 1);
if (subpath !== "/" && "serviceWorker" in navigator) {
    let registeredPaths = new Set();
    Promise.allSettled([navigator.serviceWorker.getRegistrations(), loadPathsFromDB()])
    .then(results => {
        registrations = results[0].value;
        console.log(registrations)
        if (results[1].status == 'fulfilled') {
            registeredPaths = results[1].value
        }
        let scope = subpath;
        if (registrations.length > 0) {
            registrations.forEach((registration) => {
                const tmp_url = new URL(registration.scope);
                const scope_path = tmp_url.pathname.slice(0, tmp_url.pathname.lastIndexOf('/') + 1);
                if (scope_path === subpath) {
                    console.log(registration.scope, "has registered with:", registration.active.scriptURL);
                    registration.unregister().then(function(success) {
                        if (success) {
                            console.log(registration.scope, 'unregistered');
                        } else {
                            console.log(registration.scope, 'unregister failed');
                        }
                    });
                }
                if (scope_path === "/") {
                    console.log('已加载的路径:', [...registeredPaths]);
                    if (registeredPaths.has(subpath)) {
                        scope = "/";
                    }
                }
            });
        }
        navigator.serviceWorker.register(
            subpath_service_worker
            , { "scope": scope }
        ).then((registration) => {
            console.log(subpath_service_worker + " registered with scope:", registration.scope);
        });
    })
    .catch(error => {
        console.error('Error in Promise.all:', error.message);
    });
}
</script>'''
    subpath_service_worker_js = f'''{db_op}''' + '''
const tmp_pathname = new URL(self.location.href).pathname
const subpath = tmp_pathname.slice(0, tmp_pathname.lastIndexOf('/') + 1);
let registeredPaths = new Set([subpath]);
const scope = new URL(self.registration.scope).pathname

self.addEventListener('install', (event) => {
    event.waitUntil(
        (async () => {
            try {
                if (scope.length < subpath.length) {
                    await addPathToDB(subpath);
                }
            } catch (error) {
                self.console.error('安装事件中出错:', error);
            }
            return self.skipWaiting();
        })()
    );
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        (async () => {
            try {
                if (scope.length < subpath.length) {
                    registeredPaths = await loadPathsFromDB();
                }
            } catch (error) {
                self.console.error('激活事件中出错:', error);
            }
            return self.clients.claim();
        })()
    );
});

function longestCommonPrefix(str1, str2) {
    if (str1 === str2) {
        return str1;
    }
    let minLength = Math.min(str1.length, str2.length);
    let prefix = [];
    for (let i = 0; i < minLength; i++) {
        if (str1[i] === str2[i]) {
            prefix.push(str1[i]);
        } else {
            break;
        }
    }
    return prefix.join('');
}

self.addEventListener('fetch', event => {
    event.respondWith(
        (async () => {
            let requestUrl = new URL(event.request.url);
            if (requestUrl.host === self.location.host) {
                if (event.request.referrer) {
                    const referrer = event.request.referrer;
                    let matchedPath = null;
                    for (const path of registeredPaths) {
                        if (referrer && referrer.includes(path)) {
                            matchedPath = path;
                            break;
                        }
                    }
                    if (matchedPath) {
                        const lcp = longestCommonPrefix(matchedPath, requestUrl.pathname);
                        if (lcp !== matchedPath) {
                            if (event.request.method === 'GET') {
                                const newUrl = new URL(event.request.url);
                                newUrl.pathname = requestUrl.pathname.replace(lcp, matchedPath);
                                return Response.redirect(newUrl.href, 302);
                            } else {
                                requestUrl.pathname = requestUrl.pathname.replace(lcp, matchedPath);
                                const modifiedRequest = new Request(requestUrl, {
                                    ...event.request,
                                    method: event.request.method,
                                    headers: event.request.headers,
                                    body: event.request.body,
                                    redirect: event.request.redirect,
                                    referrer: event.request.referrer,
                                    integrity: event.request.integrity,
                                    signal: event.request.signal,
                                    duplex: 'half',
                                });
                                return fetch(modifiedRequest);
                            }
                        }
                    }
                }
            } else {
                event.request.headers["cross-origin-resource-policy"] = "cross-origin";
                return fetch(event.request);
            }
            return fetch(event.request);
        })()
    );
});'''
    sw_route_B = f'''
        @routes.get("/{subpath_service_worker}")
        async def get_root(request):
            subpath_service_worker_js = """{subpath_service_worker_js}"""
            response = web.Response(text=subpath_service_worker_js)
            response.headers["Content-Type"] = "application/javascript"
            response.headers["Service-Worker-Allowed"] = "/"
            response.headers["Cache-Control"] = "no-cache"
            response.headers["Pragma"] = "no-cache"
            response.headers["Expires"] = "0"
            return response

        @routes.get("/")
        async def get_root(request):
            html_content = ""
            with open(os.path.join(self.web_root, "index.html"), 'r', encoding='utf-8') as file:
                html_content = file.read()
            if "{subpath_service_worker}" not in html_content:
                html_content = html_content.replace("</title>", """</title>\n{subpath_service_worker_script}""")
            response = web.Response(text=html_content, content_type='text/html')
        '''
    sw_route_A = r'''
        @routes.get("/")
        async def get_root(request):
            response = web.FileResponse(os.path.join(self.web_root, "index.html"))
        '''
    middleware_B = r'''
@web.middleware
async def fix_quote(request: web.Request, handler):
    from urllib.parse import urlsplit, urlunsplit, quote, unquote
    parsed_url = urlsplit(str(request.url))
    prefix = "/api/userdata/"
    if parsed_url.path.startswith(prefix):
        remaining_path = urllib.parse.unquote(parsed_url.path[len(prefix):])
        try:
            remaining_path = remaining_path.encode('latin-1').decode('utf-8')
        except:
            pass
        remaining_path = quote(remaining_path, safe=":?#[]@!$&'()*+,;=-._~").replace("%2Fmove%2Fworkflows", r"/move/workflows")
        new_url = urlunsplit((
            parsed_url.scheme,
            parsed_url.netloc,
            prefix + remaining_path,
            parsed_url.query,
            parsed_url.fragment
        ))
        cloned_request = request.clone(rel_url=new_url)
        match_info = await request.app.router.resolve(cloned_request)
        if match_info.route:
            cloned_request._match_info = match_info
            return await match_info.route.handler(cloned_request)
    return await handler(request)

def create_cors_middleware(allowed_origin: str):'''
    middleware_A = r'''
def create_cors_middleware(allowed_origin: str):'''
    server_py_path=os.path.join(comfyui_path, "server.py")
    with open(server_py_path, 'r', encoding='utf-8') as file:
        server_py_content = file.read()
    if r'''latin-1''' not in server_py_content:
        modified_server_py = server_py_content.replace(sw_route_A, sw_route_B)
        modified_server_py = modified_server_py.replace(middleware_A, middleware_B)
        modified_server_py = modified_server_py.replace(r"[cache_control", r"[cache_control, fix_quote")
        with open(server_py_path, 'w', encoding='utf-8') as file:
            file.write(modified_server_py)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Patch ComfyUI server for subpath service worker.")
    parser.add_argument("python_cmd", help="Path to the python command (e.g., python or python3)")
    parser.add_argument("comfyui_path", help="Path to ComfyUI installation folder")

    args = parser.parse_args()
    adjust_comfyUI(args.python_cmd, args.comfyui_path)