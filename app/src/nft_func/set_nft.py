from flask import render_template, redirect, session, Blueprint, request, jsonify

from src.blockchain.client import contract_client

nft_app = Blueprint("nft", __name__)


@nft_app.route("/setNFT", methods=['GET', 'POST'])
def setNFT():
    if "pk" not in session:
        return redirect("/login")

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
            return jsonify({'error': str(e)}), 500
    return render_template("setNFT.html")


@nft_app.route("/setNFTInStore", methods=['GET', 'POST'])
def setNFTInStore():
    if "pk" not in session:
        return redirect("/login")

    if request.method == "POST":
        try:
            # id_str = request.form.get("id")
            # id = int(id_str)
            # amount = int(amount_str)
            # amount_str = request.form.get("amount")
            # price_str = request.form.get("price")
            # price = int(price_str)
            
            # if not amount_str or not id_str:  # проверка на пустое значение
            #     return jsonify({'error': ' Заполните все поля'}), 400

            contract_client.to_transact(
                method_name="setNFTInStore",
                args=[
                    request.form.get("id"), 
                    request.form.get("amount"),
                    request.form.get("price")
                ],
                is_transact=True
            )
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    return render_template("setNFTInStore.html")