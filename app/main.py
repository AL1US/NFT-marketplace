from flask import Flask, render_template, request, redirect, session, jsonify, url_for
from src.blockchain.client import contract_client
from app.src.utils import ALL_METHODS

app = Flask(__name__)
app.secret_key = 'secret_key' 

@app.route("/")
def index():
    return render_template("index.html")

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        
        data = request.get_json()
        pk = data.get('pk')
        
        if not pk:
            return jsonify({'error': 'Нет публичного ключа'}), 400
        
        try:
            contract_client.set_account(pk)
            session['pk'] = pk
            
            return jsonify({
                'success': True,
            })
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return render_template("auth.html")

@app.route("/profile")
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
    
@app.route("/setNFT", methods=['GET', 'POST'])
def setNFT():
    if "pk" not in session:
        return redirect("/login")
    
    amount = int(request.form.get("amount"))

    if request.method == "POST":
        try:
            contract_client.contract.functions.setNFT(
                request.form.get("name_nft"),
                request.form.get("description"),
                request.form.get("img_nft"),
                amount
            )
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    return render_template("setNFT.html")
if __name__ == "__main__":
    app.run(debug=True)
