from flask import render_template, redirect, session, Blueprint, request, jsonify, flash

from src.blockchain.client import contract_client

auc_app = Blueprint("auc", __name__)

# GET

@auc_app.route("/auctions")
def get_auctions():
    if "public_key" not in session:
        return redirect("/login")

    public_key = session["public_key"]
    
    auctions = contract_client.to_transact(
        method_name="getAllAuctionNFTs"
    )
    
    bets = contract_client.to_transact(
        method_name="getAllBetsNFT"
    )
    
    return render_template(
        "auctions.html",
        auctions = auctions,
        bets = bets
    )


# SET AUCTION

# BET

# FINISH AUCTION

