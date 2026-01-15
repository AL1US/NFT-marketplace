from flask import render_template, redirect, session, Blueprint, request, jsonify, flash

from src.blockchain.client import contract_client

nft_app = Blueprint("nft", __name__)


@nft_app.route("/setNFT", methods=['GET', 'POST'])
def setNFT():
    if "public_key" not in session:
        return redirect("/login")
    
    contract_client.set_account(session["public_key"])

    if request.method == "POST":
        try:
            amount_str = request.form.get("amount")
            img_nft = request.form.get("img_nft")
            name_nft = request.form.get("name_nft")
            description = request.form.get("description")
            amount = int(amount_str)
            
            if not all([amount_str, img_nft, name_nft, description]):
                flash("Заполните все поля", "error")
                return render_template("setNFT.html")
            
            contract_client.to_transact(
                method_name="setNFT",
                args=[
                    name_nft,
                    description,
                    img_nft,
                    amount
                ],
                is_transact=True
            )
            
            return redirect("/profile")
        
        except Exception as e:
            flash(str(e), "error"), 500
    return render_template("setNFT.html")


@nft_app.route("/setNFTInStore/<int:id>", methods=["POST"])
def setNFTInStore(id):
    if "public_key" not in session:
        return redirect("/login")

    contract_client.set_account(session["public_key"])

    try:
        
        amount_str = request.form.get("amount") 
        price_str = request.form.get("price")
        amount = int(amount_str)
        price = int(price_str)
        
        if not all([amount_str, price_str]):
            flash('Заполните все поля!', 'error')
            return render_template("setNFTInStore.html")
        
        if amount <= 0 or price <= 0:
            flash("Количество и цена должны быть больше 0", "error")
            return redirect("/profile")
        
        contract_client.to_transact(
            method_name="setNFTInStore",
            args=[
                id,
                amount,
                price
            ],
            is_transact=True
        )
        return redirect("/")
        
    except Exception as e:
        flash(str(e), "error")
        return redirect("/profile")
        

@nft_app.route("/buy_nft/<int:index>/<int:price>", methods=["POST"])
def buy_nft(index, price):
    if "public_key" not in session:
        return redirect("/login")
    
    contract_client.set_account(session["public_key"])
    #     struct structNFTsInStore {
    #     uint256 id;
    #     address owner;
    #     uint256 amount;
    #     uint256 price;
    #     uint256 indexInStore;
    # }
        
    try:
        
        contract_client.to_transact(
                method_name="buyNFT",
                args=[
                    index,
                    1,
                ],
                is_transact=True,
                value_wei=price
            )
    except Exception as e:
        flash(str(e), "error")
        
    return redirect("/profile")


