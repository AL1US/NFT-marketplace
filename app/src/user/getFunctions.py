from flask import render_template, redirect, session, Blueprint

from src.blockchain.client import contract_client

profile_app = Blueprint("profile", __name__)

@profile_app.route("/profile")
def profile():
    if "pk" not in session:
        return redirect("/login")

    pk = session["pk"]
    pk = contract_client.w3.to_checksum_address(pk)
    
    contract_client.set_account(pk)

    user = contract_client.to_transact(method_name="getUser")
    balance = contract_client.to_transact(
        method_name="balanceOf",
        args=[pk]
    )
    
    nft = contract_client.to_transact(
        method_name="getNFT",
        args=[0]
    )
    
    return render_template(
        "profile.html",
        data=user,
        pk=pk,
        balance=balance,
        nft = nft
    )