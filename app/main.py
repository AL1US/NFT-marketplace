from flask import Flask, render_template, request, session, redirect, jsonify
from blockchain.client import contract_client
from utils.utils import render_all
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)
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
    if session.get('address') != None: return redirect('/lk')
    
    if request.method == 'POST': 
        public_key = request.json.get('public_key')
        
        res = contract_client.authorization_user(public_key)
        print(res)
        if type(res) != str and res != "Invalid key":
            session['address'] = public_key
            return jsonify({"redirect": "/profile"})
        else:
            return jsonify({"error": res}), 401      
    return render_all('auth')



if __name__ == "__main__":
    
    if contract_client.w3.is_connected():
        print("WE IN NETWORK!")
    else:
        print("HOOOOOLY SHIT")
    app.run(debug=True)