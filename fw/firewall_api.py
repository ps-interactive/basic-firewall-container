from flask import Flask, jsonify, request, session, redirect, url_for
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user
from flask_bcrypt import Bcrypt
import subprocess

app = Flask(__name__)
app.secret_key = "supersecretkey"
bcrypt = Bcrypt(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"

users = {"admin": bcrypt.generate_password_hash("password123").decode("utf-8")}

class User(UserMixin):
    def __init__(self, username):
        self.id = username

@login_manager.user_loader
def load_user(username):
    return User(username) if username in users else None

@app.route("/login", methods=["POST"])
def login():
    data = request.json
    username, password = data.get("username"), data.get("password")
    if username in users and bcrypt.check_password_hash(users[username], password):
        user = User(username)
        login_user(user)
        return jsonify({"message": "Login successful"})
    return jsonify({"error": "Invalid credentials"}), 401

@app.route("/logs", methods=["GET"])
@login_required
def get_logs():
    logs = subprocess.run(["tail", "-n", "500", "/var/log/iptables.log"], capture_output=True, text=True).stdout.splitlines()
    return jsonify({"logs": logs})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)