FROM ubuntu:focal AS builder

## install prerequisites
RUN apt update && apt -y install build-essential ocaml-nox \ 
    automake autoconf libtool wget python-is-python3 libssl-dev dkms git;

## install SDK
### tips: the version name and build name may change
RUN distro_name=ubuntu20.04-server && \
    version=2.19 && \ 
    build_name=100.3 && \
    mkdir -p /opt/intel && cd /opt/intel/ && \
    wget https://download.01.org/intel-sgx/latest/linux-latest/distro/${distro_name}/sgx_linux_x64_sdk_${version}.${build_name}.bin && \
    chmod +x sgx_linux_x64_sdk_${version}.${build_name}.bin && \
    echo "yes" | ./sgx_linux_x64_sdk_${version}.${build_name}.bin && \
    rm ./sgx_linux_x64_sdk_${version}.${build_name}.bin; \
    echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | tee /etc/apt/sources.list.d/intel-sgx.list && \
    wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add && \
    apt update && apt -y install libsgx-dcap-ql-dev libsgx-quote-ex-dev libsgx-dcap-quote-verify libsgx-dcap-quote-verify-dev;

## get sample code and modify some
RUN cd /opt/intel/sgxsdk/SampleCode && \
    git clone https://github.com/intel/SGXDataCenterAttestationPrimitives.git && \
    cp -r ./SGXDataCenterAttestationPrimitives/SampleCode/QuoteGenerationSample/ ./QuoteGenerationSample/ && \
    cp -r ./SGXDataCenterAttestationPrimitives/SampleCode/QuoteVerificationSample/ ./QuoteVerificationSample/ && \
    rm -rf ./SGXDataCenterAttestationPrimitives && \
    cd ./QuoteVerificationSample/ && \
    openssl genrsa -out Enclave/Enclave_private_sample.pem -3 3072; \
    cd /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/App && \
    rm -f ./App.cpp && \
    wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/sgxsdk/SampleCode/QuoteGenerationSample/App/App.cpp -O ./App.cpp;

## compile sample code
RUN /bin/bash -c "source /opt/intel/sgxsdk/environment && \
    cd /opt/intel/sgxsdk/SampleCode/SampleEnclave && \
    make"; \
    /bin/bash -c "source /opt/intel/sgxsdk/environment && \
    cd /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample && \
    make"; \
    /bin/bash -c "source /opt/intel/sgxsdk/environment && \
    cd /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample && \
    make && \
    sgx_sign sign -key Enclave/Enclave_private_sample.pem -enclave enclave.so -out enclave.signed.so -config Enclave/Enclave.config.xml";


# stage
FROM ubuntu:focal

## install prerequisites
RUN apt update && apt install -y wget gnupg; \
    mkdir -p /opt/intel/sgxsdk/SampleCode/SampleEnclave && \
    mkdir -p /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample && \
    mkdir -p /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample;

## install PSW
RUN echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | tee /etc/apt/sources.list.d/intel-sgx.list && \
    wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add && \
    apt update && apt -y install libsgx-epid libsgx-quote-ex libsgx-dcap-ql libsgx-dcap-default-qpl \ 
    libsgx-dcap-ql-dev libsgx-quote-ex-dev libsgx-dcap-quote-verify libsgx-dcap-quote-verify-dev;

## configure PCCS
RUN rm -f /etc/sgx_default_qcnl.conf && \
    wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/tag/v1.2_ubuntu/sgx_default_qcnl.conf -O /etc/sgx_default_qcnl.conf; \
    wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/tag/v1.2_ubuntu/SampleRun.sh -O /opt/intel/sgxsdk/SampleCode/SampleRun.sh && \
    chmod +x /opt/intel/sgxsdk/SampleCode/SampleRun.sh;

COPY --from=builder /opt/intel/sgxsdk/SampleCode/SampleEnclave/app /opt/intel/sgxsdk/SampleCode/SampleEnclave/enclave.signed.so /opt/intel/sgxsdk/SampleCode/SampleEnclave/
COPY --from=builder /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/app /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/enclave.signed.so /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/
COPY --from=builder /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample/app /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample/enclave.signed.so /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample/

CMD [ "/opt/intel/sgxsdk/SampleCode/SampleRun.sh" ]