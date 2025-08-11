# **ArtOfficial Studio: The 1-Stop Solution for Your AI Needs**

Join the community! I always love to see the work everyone is doing; it helps guide the project going forward.

[![Subscribe on YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@TheArt-OfficialTrainer)
[![Support on Patreon](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/theartofficialtrainer)
[![Join our Discord server](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/mxHCj7hxjD)
[![X](https://img.shields.io/badge/%E2%80%89X%E2%80%89-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/the_artofficial)







## **Preface**

Welcome to **ArtOfficial Studio** — a powerful Docker-based container application designed to make cutting-edge AI tools and model training accessible to everyone. The first-time set-up is simple, just install docker, and then it is only one click to pull all of the latest models, workflows, and ComfyUI features. Whether you're an artist, researcher, or enthusiast, this tool offers:

-   Works on Windows, Linux, or Cloud!
-   One-click access to the **latest AI models**
-   **SAGEATTENTION**, **TORCH COMPILE**, and **Animated Previews** just work\!
-   Simple interfaces for running various AI Tools
    -   ComfyUI
    -   Kohya_ss
    -   diffusion-pipe
    -   FluxGym
-   Easy setup of **LoRA training tools**
-   JupyterLab for full filesystem control!
-   Persistent storage for your models while always using the **latest software updates**

No technical background? No worries. This guide is written to walk you through each step from scratch. If you have any issues, chatGPT is your friend\! It is probably better at answering your questions than even I would be. I am also available on discord to help you get started, I have a dedicated channel to ArtOfficial Studio there\!

**General Installation steps:**

1. Install Docker for Linux or Windows (one-time) or access a cloud GPU through any of the providers
2. Run the docker container with an optional but recommended volume mounted so data is stored even when the docker container is deleted
3. To pull the latest changes, remove the docker container (remember, all downloaded data is stored on the volume, so it won't be deleted), pull the latest docker image, and run the docker container again. You now have a completely up to date instance of all the tools with all of your hard work still available\!

# 📘 Table of Contents

## Local Installation

1. [What is Docker? (Beginner Friendly)](#what-is-docker-beginner-friendly)
2. [How to Install Docker with GPU Support](#how-to-install-docker-with-gpu-support-one-time-setup)
    - [Windows (WSL2 + NVIDIA)](#windows-with-wsl2-and-nvidia-gpu)
    - [Linux](#linux)
5. [ArtOfficial Studio Auto Run .bat File](#ArtOfficial-Studio-Windows-Auto-Launcher)
4. [How to Run the ArtOfficial Studio Docker Image](#how-to-run-the-artofficial-studio-docker-image)
5. [Mounting a Volume Drive to Persist Data](#-mounting-a-volume-drive-to-persist-data)
6. [How to Restart the Docker Image Without Losing Data](#-how-to-restart-the-docker-image-without-losing-data)

## RunPod Cloud GPU Installation

7. [Select RunPod Template](#2-select-Proper-cuda-version-template)
8. [Optional - Create a Network Volume](#6-optional-create-a-network-volume)
9. [Deploy the Pod](#7-deploy-the-pod)

## Paperspace Cloud GPU Installation

10. [Deploy Container on GPU of Choice](#2-deploy-container-on-gpu-of-choice)
11. [Connect to Application Link](#3-connect-to-application-lin)

## SimplePod.ai Cloud GPU Installation

12. [SimplePod.ai](#simplepod-template-links)

## Using ArtOfficial Studio

13. [Using the Home Page](#app-links)
14. [Model Downloader](#model-downloader-tab)
15. [Training Tools](#training-tools-tab)
16. [CivitAI Downloader](#civitai-downloader-tab)
17. [HuggingFace Downloader](#huggingface-downloader-tab)

---

# Local Installation

## First Time Setup starts here

If your Nvidia Driver does not support cu128, there are other cuda versions available as well, if you need a different cuda version, please let me know! Not too difficult to create a new image.

`theartofficial/artofficialstudio:latest`

`theartofficial/artofficialstudio:cu126latest`

`theartofficial/artofficialstudio:cu125latest`

`theartofficial/artofficialstudio:cu124latest`

`ghcr.io/theartofficial/artofficialstudio:latest`

`ghcr.io/theartofficial/artofficialstudio:cu126latest`

`ghcr.io/theartofficial/artofficialstudio:cu125latest`

`ghcr.io/theartofficial/artofficialstudio:cu124latest`

Nvidia 50xx series requires cu128, which is why that is my official release. Drivers are backward compatible, so there is no reason not to update to the latest driver that supports the latest CUDA version. But for those who cannot, the cu126 or cu125 version should work the same.


---

## What is Docker? (Beginner Friendly)

Docker is like a virtual box that runs software in isolated environments called containers. These containers come pre-packaged with all dependencies.

Think of it like this:

1. You download an "app box"
2. You run the box
3. The app inside just works — no installs, no errors, no dependencies


---

## How to Install Docker with GPU Support (One-time setup)

### Windows (with WSL2 and NVIDIA GPU)

**Click the image below for windows install tutorial:**

[![Windows Install Guide for ArtOfficial Studio](https://img.youtube.com/vi/Na5BEQWFmic/0.jpg)](https://youtu.be/Na5BEQWFmic)

This guide will walk you through setting up Docker Desktop on Windows with WSL 2 to enable GPU acceleration for ArtOfficial Studio. This allows ArtOfficial Studio to leverage your NVIDIA graphics card for AI tasks.

**Prerequisites:**

-   A Windows machine (Windows 10 version 21H2 or higher, or Windows 11).
-   An NVIDIA GPU (Pascal architecture or newer recommended).
-   Administrator privileges on your Windows machine.

**Step 1: Install/Update NVIDIA Windows Drivers**

**This step isn't necessary if you already have your GPU drivers working.** Your Windows NVIDIA drivers are what WSL 2 and Docker will use for GPU access. 

1.  Download the official NVIDIA APP [https://www.nvidia.com/en-us/software/nvidia-app/]
2.  Download the latest **Game Ready Driver** or **NVIDIA Studio Driver** suggested for you in the app.
3.  Restart your computer if prompted.
4.  **Verify Driver Installation (Windows):** Open Command Prompt or PowerShell and type `nvidia-smi`. You should see details about your NVIDIA GPU.
5.  **Restart Docker Desktop (if already installed):** If you already have Docker Desktop installed, restart it after updating your NVIDIA drivers to ensure it recognizes the new driver version.


**Step 2: Install or Enable WSL 2**

Windows Subsystem for Linux (WSL) allows you to run a Linux environment directly on Windows. WSL 2 offers better performance and full system call compatibility, which is necessary for Docker and GPU support.

1.  **Install WSL & a Linux Distribution (e.g., Ubuntu):**
    Open PowerShell or Command Prompt **as Administrator** and run:
    ```bash
    wsl --install
    ```
    This command will enable necessary Windows features, download the latest Linux kernel, set WSL 2 as your default, and install a Linux distribution (usually Ubuntu).
2.  Restart your computer if prompted.
3.  **Update WSL (if already installed):**
    If you had WSL previously installed, ensure it's up to date:
    ```powershell
    wsl --update
    ```
4. **If Ubuntu does not automatically install:**
    Install it with:
    ```powershell
    wsl --install -d Ubuntu
    ```
6.  **Verify WSL Installation:**
    Open PowerShell or Command Prompt and run:
    ```bash
    wsl -l -v
    ```
    You should see your installed Linux distribution (e.g., Ubuntu) listed with `VERSION` as `2`. If it's version 1, you may need to convert it (e.g., `wsl --set-version Ubuntu 2`).


**Step 3: Verify WSL Has GPU Access**

Do NOT install standard Linux NVIDIA drivers inside WSL.

1.  **Open your WSL Linux Terminal:**
    Type `wsl` or the name of your distribution (e.g., `ubuntu`) in PowerShell or Command Prompt or open an Ubuntu Terminal from windows start menu

2.  **Verify `nvidia-smi` in WSL:**
    Run:
    ```bash
    nvidia-smi
    ```
    You should see details about your NVIDIA GPU.


**Step 4: Install Docker Desktop for Windows**

1.  Download Docker Desktop from the official website: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2.  Run the installer. During installation, ensure you **select the "Use WSL 2 instead of Hyper-V (recommended)" option** if prompted, or ensure it's configured to use the WSL 2 backend.
3.  After installation, Docker Desktop might require a restart.


**Step 5: Configure Docker Desktop for WSL Integration**

1.  Start Docker Desktop.
2.  Open Docker Desktop **Settings** (usually by clicking the gear icon in the top right).
3.  Go to **Resources > WSL Integration**.
4.  Ensure "Enable integration with my default WSL distro" is checked.
5.  In the list below ("Enable integration with additional distros"), make sure the toggle for your installed Linux distribution (e.g., `Ubuntu`) is **ON**.
    ![Docker WSL Integration Example](https://github.com/user-attachments/assets/7ce7ecd0-d591-4ecd-a7ad-9c526bb8523d)
6.  Click "Apply & Restart" if you made any changes.


**Step 6: Verify GPU Access in Docker**

This step confirms Docker can use your GPU via WSL 2.

1.  Open a new PowerShell, Command Prompt, or your WSL Linux terminal.
2.  Run the following command. Use a CUDA version tag that is compatible with your Windows NVIDIA driver's supported CUDA version (e.g., if `nvidia-smi` in Windows/WSL showed CUDA 12.9, use a `12.9.x` or earlier tag):
    ```bash
    docker run --rm --gpus all nvidia/cuda:12.5.0-base-ubuntu22.04 nvidia-smi
    ```
    _(You can find available `nvidia/cuda` tags on Docker Hub. For example, if your driver supports CUDA 12.9, `nvidia/cuda:12.9.0-base-ubuntu22.04` would be suitable)._
3.  If this command runs successfully and outputs the `nvidia-smi` details from _within the container_, your Docker GPU setup is working! If you see errors, re-check the previous steps, especially Windows NVIDIA drivers, WSL `nvidia-smi` functionality, and Docker Desktop WSL integration settings.


**Step 7: Troubleshooting Speed & Performance Issues in Windows**

Only use this step if you are having performance issues. For some reason docker-desktop typically only wants to use half of available resources. In this case, we need to create a .wslconfig file.
1. Create a .wslconfig file in your C:/Users/\<Username\> folder
   ![image](https://github.com/user-attachments/assets/494df023-47b5-4330-8de2-bfe3c7d70d9e)
2. Check your Task Manager > Performance Tab for the Max RAM and Processors that you have available (in this case I have 32 processors and 93.6GB RAM)
   ![image](https://github.com/user-attachments/assets/d2e36245-7206-46aa-a0ad-f72c690cb63d)
3. Write the following in your .wslconfig file:
   ```bash
    [wsl2]
    memory=<YourMaxRAM-10>GB
    processors=<YourMaxProcessors>
    ```
4. For example, for my stats, my .wslconfig file looks like:
   ```bash
    [wsl2]
    memory=80GB
    processors=32
    ```

**You are now ready to proceed with running the ArtOfficial Studio image!**


---

### Linux

[Ubuntu tutorial: How to Run Docker with GPU?](https://docs.docker.com/engine/install/)  
Official Docker install docs: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)


---


## First Time Setup Ends Here


---

## ArtOfficial Studio Windows Auto-Launcher

**If you want to just run an automated script, just download the start_aos.bat file at the top of the page and follow the instructions inside it! This will automate all the commands below for you, just remember to change "/home/theartofficial/comfyvol" to use your username.**

**DO NOT USE A WINDOWS PATH MOUNT. The Windows Path is multiple times slower than using the WSL Subsystem Path. If you want access to the linux files on Windows, either use JupyterLab through the "App Links" tab on ArtOfficial Studio, or go to the path `\\wsl$\Ubuntu` in File Explorer on Windows.**

Link: [start_aos.bat](https://github.com/TheArtOfficial/ArtOfficialStudio-Documentation/blob/main/start_aos.bat)


## Download the Docker Image

To deploy the container faster locally, it is best practice to download the container first and then run it locally. do so with this command:

```
docker pull ghcr.io/theartofficial/artofficialstudio:latest
```


## Mounting a Volume Drive to Persist Data

Docker is able to use your hard drive to store all of the contianer data. The contianer is set up so all of the important ComfyUI and Training Tool data goes into the "/workspace" folder, so that is where we want to mount our volume. Make sure you do not change the :/workspace part of the command, only change the path for your volume.

If you are running on Windows, make sure to use a path from inside the WSL distro. If you mount to a windows volume path, you **will** experience performance issues and slow loading times. These issues are completely eliminated by using a path inside WSL

When you first start WSL, it will be completely empty, as shown by the first "ls" command. "ls" just lists the files that are in the file system.
create a folder inside WSL with the "mkdir" command. In this case, I used "mkdir comfyvol"
Now when we run "ls" we can see the comfyvol folder. This will be the folder we mount our docker image too so that we can persist the data.
![image](https://github.com/user-attachments/assets/4ef75baa-585e-43ed-80a6-0a34755bebbe)


## How to Run the ArtOfficial Studio Docker Image

```bash
docker run \
  --gpus all \
  --shm-size=32g \
  -it \
  -p 80:80 \
  -v /home/theartofficial/comfyvol:/workspace \
  ghcr.io/theartofficial/artofficialstudio:latest
```

Replace the "/home/theartofficial/comfyvol" path with your actual folder location. Should be exactly the same, but replace "theartofficial" with your linux username.

Access via browser:  
http://localhost:80


---

## How to Restart the Docker Image Without Losing Data

Clean up:

```bash
docker rm -f $(docker ps -aq)
```

Then rerun the same Docker command as before.

You're all set! Dive into ArtOfficial Studio and explore the frontier of AI creation.

## How to Update your Docker Image to the Latest

Just run the pull command again

```
docker pull ghcr.io/theartofficial/artofficialstudio:latest
```

Running the container without pulling it will still update ComfyUI and all custom nodes, but you won't have any of the new ArtOfficial Studio features released, so if you want to try out a new model or new training too that's been released, make sure to pull the image again.

## Run the Container Again

```bash
docker run \
  --gpus all \
  --shm-size=32g \
  -it \
  -p 80:80 \
  -v /home/theartofficial/comfyvol:/workspace \
  ghcr.io/theartofficial/artofficialstudio:latest
```

Replace the "/home/theartofficial/comfyvol" path with your actual folder location. Should be exactly the same, but replace "theartofficial" with your linux username.

Access via browser:  
http://localhost:80

---

# Runpod Installation

If your pod's driver does not support cu128, there are other versions available.

To filter Pods by cuda version, use this dropdown (Cu12.8 Template won't work with Pods that have <=Cu12.7):
![image](https://github.com/user-attachments/assets/03a879c6-140a-44f3-a678-e5287892acaa)

## How to Install the Container on a Cloud GPU with RunPod (Process for other cloud services should be similar)

**A warning before we begin, this does take longer to start than most Comfy Templates on RunPod, but that is because it gives you EVERYTHING you need. From Lora training tools, to Sageattention, to Controlnets, you won't have to search around the internet to find projects, nodes or models, so although the startup time is high, it will save you time overall.**

### 1. Go to RunPod:

-   Sign in to your account at [RunPod.io](https://runpod.io).

### 2. Select Proper Cuda Version Template

Cu12.8: https://console.runpod.io/deploy?template=xhqk6am365&ref=sibibj3j

Cu12.6: https://console.runpod.io/deploy?template=gyub8b38nt&ref=sibibj3j

Cu12.5: https://console.runpod.io/deploy?template=w15kdsstbq&ref=sibibj3j

Cu12.4: https://console.runpod.io/deploy?template=6pa9vb4956&ref=sibibj3j


### 7. Deploy On-Demand:

-   Click **Deploy On-Demand**. You should see the logs start to run.
-   If you encounter an error such as "No container found," this may indicate a network or setup issue with the pod.

### 8. Verify Logs:

-   Once successful, your system logs should indicate that everything is running, and you'll see messages like "downloading ------>" if it's your first time using the template.
-   If you see an "unauthorized" error, this means the credentials are incorrect or access hasn't been granted yet.

![Screenshot from 2025-04-24 07-14-34](https://github.com/user-attachments/assets/e87e1d8f-ba3c-4508-871b-576617aa2d32)

### 9. Connect:

-   Once everything is working, the **Connect** button will become active. Click it to access your container.

![Screenshot from 2025-04-24 07-18-33](https://github.com/user-attachments/assets/06c41b13-38c5-4fc3-8ecb-106f740bd15a)

### 10. Connect to port 80:

-   The app runs on port 80, so click that and the front-end UI will open.

By following these steps, you'll have a fully working setup with the ArtOfficial Studio container running on your RunPod cloud GPU!


---

# Paperspace Installation

### 1. **Deploy Container on GPU of Choice**

-   use the docker image that is compatible with your GPU
    `ghcr.io/theartofficial/artofficialstudio:latest`  
    `ghcr.io/theartofficial/artofficialstudio:cu126latest`
    `ghcr.io/theartofficial/artofficialstudio:cu125latest`
    `ghcr.io/theartofficial/artofficialstudio:cu124latest`

![image](https://github.com/user-attachments/assets/56f2c98a-b8b0-4b2f-93df-66400fb1a519)

-   Make sure port 80 is exposed, then click "DEPLOY"

![image](https://github.com/user-attachments/assets/74ea9b96-a6d5-4b0b-a2da-703a30a342b4)

### 2. **Connect to Application Link**

-   Once you see tensorboard messages at the end of the log, your instance is ready to go!

![Screenshot from 2025-04-25 13-19-28](https://github.com/user-attachments/assets/98f47462-a36a-4886-a7f7-3e969eb199eb)

-   From the console dashboard, click the "Endpoint" Link, and you will be connected to the App Links page of the application!

![image](https://github.com/user-attachments/assets/68e28f57-103c-48d9-982f-f0df5509c25a)


---

# Simplepod.ai 

### Simplepod Template Links:

Cu12.8: [https://dash.simplepod.ai/account/explore/65/ref-fh2t1wmai/rrit_hDt1yWltmZf7](https://dash.simplepod.ai/account/explore/65/ref-fh2t1wmai/rrit_hDt1yWltmZf7)

Cu12.6: [https://dash.simplepod.ai/account/explore/66/ref-fh2t1wmai/rrit_RFitDhs1pNS1](https://dash.simplepod.ai/account/explore/66/ref-fh2t1wmai/rrit_RFitDhs1pNS1)

Cu12.5: [https://dash.simplepod.ai/account/explore/67/ref-fh2t1wmai/rrit_iCtt3n219R3J](https://dash.simplepod.ai/account/explore/67/ref-fh2t1wmai/rrit_iCtt3n219R3J)

Cu12.4: [https://dash.simplepod.ai/account/explore/68/ref-fh2t1wmai/rrit_TTyLUw4bUUM1](https://dash.simplepod.ai/account/explore/68/ref-fh2t1wmai/rrit_TTyLUw4bUUM1)


---

# Using ArtOfficial Studio

## To launch ArtOfficial Studio:

Local: Navigate to `http://localhost:80/`

Runpod: Connect to port 80

Paperspace: just navigate to the url provided by the by Paperspace.

## App Links

App links provides all of the connections to other services maintained by the app

![image](https://github.com/user-attachments/assets/b4ba566a-99e2-4496-8dea-0f30cbff842b)

## Model Downloader Tab

The **Model Downloader** tab allows you to select and download models straight into the correct folder for **ComfyUI**. Once downloaded, Head to the "App Links" tab to access **ComfyUI**. Models should be automatically placed in the correct directories.

![Screenshot from 2025-04-25 11-02-51](https://github.com/user-attachments/assets/1f25722f-6ca8-4e84-a691-c11b5034574a)

## Training Tools Tab

This tab provides tools to train LoRAs. Select a tool and hit install. The installation logs will appear in the **Installation Log** box. If any errors occur, you can send the logs for troubleshooting.

-   Diffusion Pipe is tested and working well
-   FluxGym Installation is clean, need to test functionality
-   Kohya Installation is clean, need to test functionality

![Screenshot from 2025-04-25 11-03-05](https://github.com/user-attachments/assets/df25ce90-4e43-48a7-b402-87fe279edd24)

## CivitAI Downloader Tab

This feature allows you to download files from CivitAI. Simply provide the URL, model type, desired filename, and your CivitAI token, and it will automatically place the file in the right ComfyUI folder.

![Screenshot from 2025-04-25 11-03-23](https://github.com/user-attachments/assets/80851482-7170-4b8b-9ac5-e949acd15730)

## HuggingFace Downloader Tab:

Similar to the CivitAI downloader, this tool allows you to download models from HuggingFace by providing the URL, download path, and optionally a HuggingFace token.
![Screenshot from 2025-04-25 11-03-36](https://github.com/user-attachments/assets/530dd127-e771-4840-99d4-ce9285999249)

---
