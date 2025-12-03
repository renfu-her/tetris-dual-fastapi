"""Gunicorn configuration file for Tetris Dual Backend."""
import multiprocessing
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Server socket
bind = f"{os.getenv('HOST', '0.0.0.0')}:{os.getenv('PORT', '8000')}"
backlog = 2048

# Worker processes
workers = int(os.getenv('WORKERS', multiprocessing.cpu_count() * 2 + 1))
worker_class = 'uvicorn.workers.UvicornWorker'
worker_connections = 1000
timeout = 30
keepalive = 2

# Logging
accesslog = '-'  # Log to stdout
errorlog = '-'   # Log to stderr
loglevel = os.getenv('LOG_LEVEL', 'info')
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'tetris-dual-backend'

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# SSL (optional, uncomment if needed)
# keyfile = '/path/to/keyfile.key'
# certfile = '/path/to/certfile.crt'

# Reload on code changes (development only)
reload = os.getenv('RELOAD', 'False').lower() == 'true'

# Pre/Post fork hooks
def on_starting(server):
    """Called just before the master process is initialized."""
    print("🚀 Starting Tetris Dual Backend with Gunicorn...")


def when_ready(server):
    """Called just after the server is started."""
    print(f"✅ Server is ready. Listening on {bind}")


def on_exit(server):
    """Called just before the server is shut down."""
    print("👋 Shutting down Tetris Dual Backend...")

