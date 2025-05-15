from flask import Flask, request, jsonify
import os, re, cv2
from paddleocr import PaddleOCR
from openai import OpenAI

app = Flask(__name__)
ocr = PaddleOCR(lang="korean")

# ───────────────────────────────────────────────────────────
# 🔐 OpenAI API 키 설정 방법 (중요!!)
#
# ✅ 방법 1: 환경 변수로 안전하게 설정 (추천)
#   - 아래 코드는 환경변수에서 "OPENAI_API_KEY" 라는 이름으로 키를 불러옵니다.
#   - 보안에 안전하고 GitHub에 올려도 유출되지 않습니다.
#
#       PowerShell이나 터미널에서 다음과 같이 입력하세요:
#       $env:OPENAI_API_KEY="sk-여기에-너의-OpenAI-키"
#
# ✅ 방법 2: 테스트용으로 코드에 직접 키를 넣기 (보안 위험 있음❌)
#   - 아래 주석을 해제하고 실제 키를 문자열로 입력하세요.
#   - 절대 깃허브에 업로드하지 마세요!!!
#
#       client = OpenAI(api_key="sk-너의-API-키")
# ───────────────────────────────────────────────────────────

# 환경변수에서 키 불러오기 (실제 사용되는 줄)
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# 직접 키 입력 (테스트용, 사용 시 위 줄 주석 처리하고 아래 주석 해제)
# client = OpenAI(api_key="sk-여기에-API-키-직접-넣기❌")

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files.get("image")
    if not file:
        return jsonify({"error": "이미지 파일이 없습니다."}), 400

    os.makedirs("uploads", exist_ok=True)
    path = os.path.join("uploads", file.filename)
    file.save(path)

    try:
        text = extract_text(path)
        prompt = create_prompt(text)
        result = ask_gpt(prompt)
        return jsonify({"result": result})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def extract_text(image_path):
    result = ocr.ocr(image_path, cls=True)
    texts = []
    for line in result:
        for word_info in line:
            text = word_info[1][0]
            cleaned = re.sub(r"[^가-힣a-zA-Z0-9\s]", "", text)
            texts.append(cleaned.strip())
    return " ".join(texts)

def create_prompt(text_block):
    return (
        "다음은 OCR로 추출된 텍스트입니다. 이 중 약 이름만 추출해 주세요:\n\n"
        f"{text_block}\n\n"
        "약 이름 목록:"
    )

def ask_gpt(prompt_text):
    resp = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "너는 약 이름에 대해 잘 아는 전문가야."},
            {"role": "user", "content": prompt_text}
        ],
        temperature=0.4,
        max_tokens=500
    )
    return resp.choices[0].message.content

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
