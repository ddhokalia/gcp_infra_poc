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

# create cf (from repo root)
gcloud infra-manager deployments apply \
  projects/slw-patenthub-dev/locations/us-central1/deployments/poc-genai \
  --git-source-repo="https://github.com/ddhokalia/gcp_infra_poc.git" \
  --git-source-directory="infra/deployments/poc_deployment" \
  --git-source-ref="master" \
  --service-account="projects/slw-patenthub-dev/serviceAccounts/infra-sa@slw-patenthub-dev.iam.gserviceaccount.com"
