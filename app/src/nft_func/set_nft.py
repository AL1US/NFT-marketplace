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
            if not amount_str:  # проверка на пустое значение
                return jsonify({'error': 'Amount не указан'}), 400
            amount = int(amount_str)

            contract_client.to_transact(
                method_name="setNFT",
                args=[
                    request.form.get("name_nft"),
                    request.form.get("description"),
                    request.form.get("img_nft"),
                    amount
                ],
                is_transact=True
            )
        
        except Exception as e:
            flash({'error': str(e)}), 500
    return render_template("setNFT.html")


@nft_app.route("/setNFTInStore", methods=['GET', 'POST'])
def setNFTInStore():
    if "public_key" not in session:
        return redirect("/login")

    contract_client.set_account(session["public_key"])
    
    
    if request.method == "POST":
        try:
            nft_id = request.form.get("id")
            amount_str = request.form.get("amount") 
            price_str = request.form.get("price")
            
            if not all([nft_id, amount_str, price_str]):
                flash('Заполните все поля!', 'error')
                return render_template("setNFTInStore.html")
            
            id = int(nft_id)
            amount = int(amount_str)
            price = int(price_str)
            
            contract_client.to_transact(
                method_name="setNFTInStore",
                args=[
                    id,
                    amount,
                    price
                ],
                is_transact=True
            )
            
        except Exception as e:
            flash({'error': str(e)}), 500
    return render_template("setNFTInStore.html")
