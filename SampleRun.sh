#!/bin/bash
echo "Sample Enclave"
cd /opt/alibaba/SGXProgram/SampleCode/SampleEnclave && ./app

echo ""
echo "Generate Quote"
cd /opt/alibaba/SGXProgram/SampleCode/QuoteGenerationSample && ./app && ls -ll

echo ""
echo "Verify Quote"
cd /opt/alibaba/SGXProgram/SampleCode/QuoteVerificationSample && ./app && ls -ll ../QuoteGenerationSample
