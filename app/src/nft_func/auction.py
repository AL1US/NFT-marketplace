from flask import render_template, redirect, session, Blueprint, request, jsonify, flash

from src.blockchain.client import contract_client

auc_app = Blueprint("auc", __name__)

# GET

@auc_app.route("/auctions")
def get_auctions():
    if "public_key" not in session:
        return redirect("/login")

    auctions_raw = contract_client.to_transact(
        method_name="getAllAuctionNFTs"
    )

    auctions = []

    for auc in auctions_raw:
        bet = contract_client.to_transact(
            method_name="getBetNFT",
            args=[auc[0]]  # auc.id
        )

        auctions.append({
            "auction": auc,
            "bet": bet
        })

    return render_template(
        "auctions.html",
        auctions=auctions
    )



# SET AUCTION

@auc_app.route("/setAucNFT/<int:id>", methods=["POST"])
def setAucNFT(id):
    if "public_key" not in session:
        return redirect("/login")

    contract_client.set_account(session["public_key"])

    try:
        
        amount_str = request.form.get("amount") 
        min_bet_str = request.form.get("min_bet")
        end_auction_str = request.form.get("end_auction")
        amount = int(amount_str)
        min_bet = int(min_bet_str)
        end_auction = int(end_auction_str)
        
        if not all([amount_str, min_bet_str]):
            flash('Заполните все поля!', 'error')
            return render_template("setNFTInStore.html")
        
        if amount <= 0 or min_bet <= 0:
            flash("Количество и минимальная ставка должны быть больше 0", "error")
            return redirect("/profile")
        
        contract_client.to_transact(
            method_name="setAuctionNFT",
            args=[
                id,
                min_bet,
                end_auction,
                amount
            ],
            is_transact=True
        )
        return redirect("/auctions")
        
    except Exception as e:
        flash(str(e), "error")
    return redirect("/profile")
        

# BET

@auc_app.route("/setBet/<int:id>", methods=["POST"])
def setBet(id):
    if "public_key" not in session:
        return redirect("/login")

    contract_client.set_account(session["public_key"])

    try:
        
        amount_str = request.form.get("amount") 
        amount = int(amount_str)
        
        if not amount_str:
            flash('Заполните все поля!', 'error')
            return render_template("setNFTInStore.html")
        
        if amount <= 0:
            flash("Количество должно быть больше 0", "error")
            return redirect("/profile")
        
        contract_client.to_transact(
            method_name="setBetNFT",
            args=[
                id,
                amount
            ],
            is_transact=True
        )
        return redirect("/auctions")
        
    except Exception as e:
        flash(str(e), "error")
    return redirect("/profile")


# FINISH AUCTION

