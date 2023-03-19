#!/bin/bash
echo "Sample Enclave"
cd /opt/intel/sgxsdk/SampleCode/SampleEnclave && ./app

echo ""
echo "Generate Quote"
cd /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample && ./app -quote /tmp/SGXSampleCode/quote.dat

echo ""
echo "QuoteGenerationSample Directory"
ls -ll /opt/intel/sgxsdk/SampleCode/QuoteGenerationSample

echo ""
echo "Verify Quote"
cd /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample && ./app -quote /tmp/SGXSampleCode/quote.dat

echo ""
echo "QuoteGenerationSample Directory"
cd /opt/intel/sgxsdk/SampleCode/QuoteVerificationSample && ls -ll ../QuoteGenerationSample