from flask import Flask, render_template, request, redirect, session, jsonify, url_for

from src.blockchain.client import contract_client
from src.user.account import user_app
from src.user.profile import profile_app
from src.nft_func.set_nft import nft_app

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
    
    if "public_key" not in session:
        return redirect("/login")

    public_key = session["public_key"]
    
    nft = contract_client.to_transact(
        method_name="getAllStoreNFTs",
    )
    
    return render_template(
        "index.html",
        nft = nft
    )
    

if __name__ == "__main__":
    app.run(debug=True)
