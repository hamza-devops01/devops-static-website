# 🚀 DevOps Intern Project – CI/CD Pipeline for Static Website Deployment

## 📖 Project Overview

This project demonstrates a complete **CI/CD (Continuous Integration and Continuous Deployment)** pipeline using **GitHub Actions** to automatically deploy a static website to **Amazon S3**.

The objective of this project is to understand the DevOps workflow by automating the deployment process. Whenever code is pushed to the **main** branch, GitHub Actions automatically deploys the latest version of the website to an AWS S3 bucket.

---

## 🎯 Objectives

- Learn Git and GitHub
- Understand DevOps Fundamentals
- Build a Static Website
- Create a CI/CD Pipeline
- Deploy Website to AWS S3
- Learn GitHub Actions

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| Git | Version Control |
| GitHub | Source Code Management |
| GitHub Actions | CI/CD Pipeline |
| HTML5 | Website Structure |
| CSS3 | Website Styling |
| JavaScript | Website Interactivity |
| AWS S3 | Static Website Hosting |
| AWS IAM | Secure AWS Access |
| AWS CLI | Deployment |

---

## 📁 Project Structure

```text
DevOps-Intern-Project/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── images/
│
├── index.html
├── style.css
├── script.js
├── README.md
└── LICENSE
```

---

## ⚙️ Prerequisites

Before running this project, make sure you have:

- Git
- Visual Studio Code
- GitHub Account
- AWS Free Tier Account
- AWS CLI Installed

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/hamza-devops01/devops-static-website.git
```

### 2. Navigate to the Project

```bash
cd devops-static-website
```

### 3. Make Changes

Edit your HTML, CSS, or JavaScript files.

### 4. Push Changes

```bash
git add .
git commit -m "Update website"
git push origin main
```

GitHub Actions will automatically deploy your website.

---

## ⚡ CI/CD Workflow

```text
Developer
    │
    ▼
Write Code
    │
    ▼
Git Commit
    │
    ▼
Git Push
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions Triggered
    │
    ▼
Checkout Repository
    │
    ▼
Configure AWS Credentials
    │
    ▼
Deploy to Amazon S3
    │
    ▼
Website Updated Automatically
```

---

## Live Demo
🔗 **View the live website**: http://project-deploy-hs-2026.s3-website-eu-west-1.amazonaws.com

---

## 🙏 Acknowledgements

This project was completed as part of a **DevOps Internship Program** to gain practical experience with:

- Git
- GitHub
- GitHub Actions
- AWS S3
- CI/CD Pipelines
- Deployment Automation

---

⭐ If you found this project helpful, please consider giving it a **star** on GitHub!
