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
