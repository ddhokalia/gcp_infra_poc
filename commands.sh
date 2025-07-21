# create GAR
gcloud artifacts repositories create genai-utils \
  --repository-format=python \
  --location=us-central1 \
  --description="Python shared utils for CFs"

# build the dist wheel
cd genai_utils
python3 setup.py bdist_wheel

# upload the dist wheel to GAR
twine upload \
  --repository-url "https://us-central1-python.pkg.dev/YOUR_PROJECT_ID/genai-utils/" \
  dist/*.whl

