# v1.2

## builder for compiling
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:220901.1 AS builder

## install SDK and other dependencies
RUN region_id=cn-shanghai && \
    yum install -y wget yum-utils && \
    yum-config-manager --add-repo \
    https://enclave-${region_id}.oss-${region_id}-internal.aliyuncs.com/repo/alinux/enclave-expr.repo; \
    yum install -y sgxsdk; \
    yum groupinstall -y "Development Tools"; \
    yum install -y libsgx-dcap-ql-devel libsgx-dcap-quote-verify-devel;

## modify source code
RUN cd /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteGenerationSample/App && \
    rm -f ./App.cpp && wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/sgxsdk/SampleCode/QuoteGenerationSample/App/App.cpp -O ./App.cpp;

## compile and sign
RUN source /opt/alibaba/teesdk/intel/sgxsdk/environment && \
    cd /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/SampleEnclave && \
    make; \
    source /opt/alibaba/teesdk/intel/sgxsdk/environment && \
    cd /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteGenerationSample && \
    make; \
    source /opt/alibaba/teesdk/intel/sgxsdk/environment && \
    cd /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteVerificationSample && \
    make && \
    sgx_sign sign -key Enclave/Enclave_private_sample.pem -enclave enclave.so -out enclave.signed.so -config Enclave/Enclave.config.xml;


## stage for executing
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:220901.1

## install PSW
RUN region_id=cn-shanghai && \
    yum install -y wget yum-utils && \
    yum-config-manager --add-repo \
    https://enclave-${region_id}.oss-${region_id}-internal.aliyuncs.com/repo/alinux/enclave-expr.repo; \
    yum install -y libsgx-ae-le libsgx-ae-pce libsgx-ae-qe3 libsgx-ae-qve \
    libsgx-aesm-ecdsa-plugin libsgx-aesm-launch-plugin libsgx-aesm-pce-plugin \
    libsgx-aesm-quote-ex-plugin libsgx-dcap-default-qpl libsgx-dcap-ql \
    libsgx-dcap-quote-verify libsgx-enclave-common libsgx-launch libsgx-pce-logic \
    libsgx-qe3-logic libsgx-quote-ex libsgx-ra-network libsgx-ra-uefi \
    libsgx-uae-service libsgx-urts sgx-ra-service sgx-aesm-service;

## configure remote attestation config file and get shell script
RUN region_id=cn-shanghai && \ 
    PCCS_URL=https://sgx-dcap-server-vpc.${region_id}.aliyuncs.com/sgx/certification/v3/ && \
    echo "PCCS_URL=${PCCS_URL}" >> /etc/sgx_default_qcnl.conf && \
    echo "USE_SECURE_CERT=TRUE" >> /etc/sgx_default_qcnl.conf; \
    mkdir -p /opt/alibaba/SGXProgram/SampleCode/SampleEnclave && \
    mkdir -p /opt/alibaba/SGXProgram/SampleCode/QuoteGenerationSample && \
    mkdir -p /opt/alibaba/SGXProgram/SampleCode/QuoteVerificationSample; \
    wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/tag/v1.2_alilinux/SampleRun.sh -O /opt/alibaba/SGXProgram/SampleRun.sh && \
    chmod +x /opt/alibaba/SGXProgram/SampleRun.sh

## copy binary files
COPY --from=builder /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/SampleEnclave/app /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/SampleEnclave/enclave.signed.so /opt/alibaba/SGXProgram/SampleCode/SampleEnclave/
COPY --from=builder /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteGenerationSample/app /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteGenerationSample/enclave.signed.so /opt/alibaba/SGXProgram/SampleCode/QuoteGenerationSample/
COPY --from=builder /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteVerificationSample/app /opt/alibaba/teesdk/intel/sgxsdk/SampleCode/QuoteVerificationSample/enclave.signed.so /opt/alibaba/SGXProgram/SampleCode/QuoteVerificationSample/

CMD [ "/opt/alibaba/SGXProgram/SampleRun.sh" ]