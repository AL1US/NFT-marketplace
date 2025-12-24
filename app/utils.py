from flask import session, redirect
ALL_METHODS = ["GET", "POST"]

def check_session():
    if session.get["address"] != None:
        return redirect("/profile")
    else:
        return redirect("/auth")