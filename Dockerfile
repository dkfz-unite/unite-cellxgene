FROM python:3.10-slim AS base
ENV URL_PREFIX=""
ENV FILE_PATH=""
EXPOSE 80
EXPOSE 443

FROM python:3.10-slim AS install
RUN apt-get update
RUN apt-get install -y build-essential make jq nodejs npm
RUN apt-get clean

FROM install AS build
WORKDIR /app
COPY . .
RUN pip install wheel
RUN pip install -r requirements.txt
RUN make build-for-server-dev
RUN python ./setup.py bdist_wheel

FROM base AS runtime
WORKDIR /app
COPY --from=build /app/dist/*.whl .
RUN pip install --no-cache-dir wheel
RUN pip install --no-cache-dir *.whl
CMD cellxgene launch --disable-annotations --disable-gene-sets-save --host 0.0.0.0 --port 80 --url-prefix ${URL_PREFIX} /app/data/${FILE_PATH}
# CMD cellxgene launch --backed --disable-diffexp --disable-annotations --disable-gene-sets-save --host 0.0.0.0 --port 80 --url-prefix ${URL_PREFIX} /app/data/${FILE_PATH}
# docker run -v ~/mnt/analysis:/app/data -p 5005:80 -e URL_PREFIX="/cxg" -e FILE_PATH="data.h5ad" cellxgene
