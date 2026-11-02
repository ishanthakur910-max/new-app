# TaskFlow — Docker Compose + Jenkins + AWS EC2

Full-stack task manager: Nginx frontend, Node/Express API, PostgreSQL database, Docker Compose, and a Jenkins deployment pipeline.

## Run locally
Install Docker Engine and the Compose plugin, then:
```bash
cp .env.example .env
# Edit .env and set a strong DB_PASSWORD
docker compose up -d --build
docker compose ps
```
Open http://localhost. Health endpoint: http://localhost/api/health

Useful commands:
```bash
docker compose logs -f
docker compose down
```
`docker compose down` keeps database data in its named volume. `docker compose down -v` deletes it.

## Two-EC2 deployment
- Jenkins EC2: Jenkins pipeline agent.
- App EC2: Ubuntu, Docker Engine and Compose plugin.

On the app EC2, allow SSH (22) only from Jenkins EC2's security group and HTTP (80) from users if the site is public. Ensure `ubuntu` can run Docker. For this learning lab:
```bash
sudo usermod -aG docker ubuntu
```
Log out and back in after changing group membership. Docker group access is effectively root-level access.

## Your local Zorin key: zorin.pem
If the key is in Downloads, connect from your Zorin PC with:
```bash
chmod 400 ~/Downloads/zorin.pem
ssh -i ~/Downloads/zorin.pem ubuntu@YOUR_APP_EC2_PUBLIC_IP
```
Replace the placeholder with your app EC2 public IP. This local key is not automatically available to Jenkins. Jenkins needs a private key stored in Jenkins Credentials, and its matching public key must be authorized on the app EC2.

## Jenkins setup
1. Install/enable the **SSH Agent** plugin.
2. Add credential: Kind **SSH Username with private key**, username `ubuntu`, ID `taskflow-deploy-key`.
3. Paste a private key whose matching public key is in the app EC2 user's `~/.ssh/authorized_keys`. Never commit private keys to GitHub.
4. Edit `APP_HOST` in the Jenkinsfile to the app EC2 public IP (or private IP if routing/security groups permit).
5. Jenkins agent needs `docker`, `docker compose`, `ssh`, `rsync`, and `curl`. It builds images for validation; remote host builds and starts the Compose stack.
6. Push to GitHub and configure a webhook to trigger Jenkins.

## API
- `GET /api/health`
- `GET /api/tasks`
- `POST /api/tasks` JSON: `{ "title": "Example", "description": "Details", "priority": "High" }`
- `PATCH /api/tasks/:id` JSON: `{ "status": "Completed" }`
- `DELETE /api/tasks/:id`

## Security note
This is a learning project, not production-hardened. Change the demo DB password, keep `.env` off Git, and add HTTPS, authentication, backups, least-privilege access, and secret management before real use.
