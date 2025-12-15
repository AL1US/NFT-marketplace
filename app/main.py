from flask import Flask, render_template
from web3_connect.connect import contract

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/store")
def store():
    return render_template("store.html")

@app.route("/auctions")
def auctions():
    return render_template("auctions.html")

@app.route("/profile")
def profile():
    return render_template("profile.html")

@app.route("/setNFT")
def setNFT():
    return render_template("setNFT.html")

@app.route("/login", methods=["POST", "GET"])
def login():
    return render_template("auth.html")


if __name__ == "__main__":
    app.run(debug=True)