from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/recommend', methods=['POST'])

def recommend():

    data = request.json

    history = data['history']

    recommendations = [
        "Iron Man",
        "Justice League",
        "Captain America"
    ]

    return jsonify({
        "recommendations": recommendations
    })

if __name__ == "__main__":

    app.run(port=5000)