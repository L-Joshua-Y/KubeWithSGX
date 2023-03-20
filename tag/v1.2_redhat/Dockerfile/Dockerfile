FROM redhat/ubi8:8.6-903 AS builder

## install prerequisites
### mirrorlist=https://mirrors.cloud.tencent.com/redhat/rhel/rhel-8-beta
### protobuf doesn't locate in the default source list so we need to cahnge source
RUN cd /tmp && \
    yum -y install wget yum-utils && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum install -y https://mirrors.cloud.tencent.com/redhat/rhel/rhel-8-beta/appstream/x86_64/Packages/protobuf-3.5.0-7.el8.x86_64.rpm \
    autoconf automake binutils gcc gcc-c++ gdb glibc-devel libtool make pkgconf pkgconf-m4 \ 
    pkgconf-pkg-config redhat-rpm-config rpm-build git perl-Fedora-VSP perl-Sys-Syslog perl-generators cmake;

## add repo
RUN mkdir -p /opt/intel/ && \
    cd /opt/intel/ && \
    wget https://download.01.org/intel-sgx/sgx-linux/2.19/distro/rhel8.6-server/sgx_rpm_local_repo.tgz -O sgx_rpm_local_repo.tgz && \
    tar xvf sgx_rpm_local_repo.tgz && \
    yum-config-manager --add-repo file:///opt/intel/sgx_rpm_local_repo && \
    rm -f sgx_rpm_local_repo.tgz;

## install SDK
RUN cd /opt/intel/ && \
    distro_name=rhel8.6-server && version=2.19 && build_name=100.3 && \
    wget https://download.01.org/intel-sgx/sgx-linux/2.19/distro/${distro_name}/sgx_linux_x64_sdk_${version}.${build_name}.bin && \
    chmod +x sgx_linux_x64_sdk_${version}.${build_name}.bin && \
    echo "yes" | ./sgx_linux_x64_sdk_${version}.${build_name}.bin && \
    rm -f ./sgx_linux_x64_sdk_${version}.${build_name}.bin; \
    yum install -y --nogpgcheck libsgx-launch libsgx-epid libsgx-quote-ex; \
    yum install -y --nogpgcheck libsgx-enclave-common-devel libsgx-dcap-ql-devel \ 
    libsgx-dcap-default-qpl-devel libsgx-quote-ex-devel libsgx-launch-devel \ 
    libsgx-epid-devel libsgx-dcap-ql-devel libsgx-dcap-quote-verify-devel;

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



FROM redhat/ubi8:8.6-903

## add repo
RUN mkdir -p /opt/intel/ && \
    cd /opt/intel/ && \
    yum -y install wget yum-utils && \
    wget https://download.01.org/intel-sgx/sgx-linux/2.19/distro/rhel8.6-server/sgx_rpm_local_repo.tgz -O sgx_rpm_local_repo.tgz && \
    tar xvf sgx_rpm_local_repo.tgz && \
    yum-config-manager --add-repo file:///opt/intel/sgx_rpm_local_repo && \
    rm -f sgx_rpm_local_repo.tgz; \
    mkdir -p /opt/intel/sgxsdk/SampleCode/SampleEnclave && \
    mkdir -p /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample && \
    mkdir -p /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample;

## install PSW
RUN dnf --nogpgcheck -y install libsgx-urts libsgx-launch libsgx-epid libsgx-quote-ex \ 
    libsgx-dcap-ql libsgx-dcap-default-qpl; \
    dnf --nogpgcheck -y install libsgx-dcap-quote-verify;

## configure PCCS and add shell script
RUN rm -f /etc/sgx_default_qcnl.conf && \
    wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/tag/v1.2_redhat/sgx_default_qcnl.conf -O /etc/sgx_default_qcnl.conf; \
    wget https://raw.githubusercontent.com/L-Joshua-Y/KubeWithSGX/main/tag/v1.2_redhat/SampleRun.sh -O /opt/intel/sgxsdk/SampleCode/SampleRun.sh && \
    chmod +x /opt/intel/sgxsdk/SampleCode/SampleRun.sh;

COPY --from=builder /opt/intel/sgxsdk/SampleCode/SampleEnclave/app /opt/intel/sgxsdk/SampleCode/SampleEnclave/enclave.signed.so /opt/intel/sgxsdk/SampleCode/SampleEnclave/
COPY --from=builder /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/app /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/enclave.signed.so /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample/
COPY --from=builder /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample/app /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample/enclave.signed.so /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample/

CMD [ "/opt/intel/sgxsdk/SampleCode/SampleRun.sh" ]