from flask import Flask, render_template, request, redirect, session, jsonify, url_for

from src.blockchain.client import contract_client
from src.user.account import user_app
from src.user.getFunctions import profile_app
from src.nft.setFunctions import nft_app

app = Flask(__name__)
app.secret_key = 'secret_key' 

app.register_blueprint(user_app)
app.register_blueprint(profile_app)
app.register_blueprint(nft_app)

# 404 обработчик
@app.errorhandler(404)
def page_not_found(error):
    return render_template('page404.html'), 404

@app.route("/")
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True)
