from flask import render_template, redirect, session, Blueprint

from src.blockchain.client import contract_client

profile_app = Blueprint("profile", __name__)

@profile_app.route("/profile")
def profile():
    if "public_key" not in session:
        return redirect("/login")

    public_key = session["public_key"]

    user = contract_client.to_transact(method_name="getUser")
    balance = contract_client.to_transact(
        method_name="balanceOf",
        args=[public_key]
    )
    
    nft = contract_client.to_transact(
        method_name="getMyAllNFTs",
    )
    
    collection = contract_client.to_transact(
        method_name="getMyCollections",
    )
    
    return render_template(
        "profile.html",
        data=user,
        public_key=public_key,
        balance=balance,
        nft = nft,
        collection = collection
    )