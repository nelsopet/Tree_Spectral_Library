#!/bin/bash

AUTHTOKEN=ya29.a0ARrdaM-hWqFWH7aD2KkJERxEtmSvqbuN-0yRVC6gdRsGgXnhZT778c5bJqB6AKP5WBR0mvh3Iq9hz_acZ7EvbRvqwBqIDccugvs5StvT108U_lEyGMsjiCzB0zbfnl73LWQW4ppr_CBsDAwjMs3oN9c3RAJA
outputFolder=E:/lecospec/

# download files from Google Drive automatically:
#curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1feK8G_r1B0fjxkOPB2zoM14qRIlBd461?alt=media -o $outputFolder/raw_2000_rd_rf_or
#curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1SI8OsOBGZrJKFVJfP-MtbGPKAVRPBV1y?alt=media -o $outputFolder/raw_2000_rd_rf_or.hdr
#curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1lo-uBH4wAXCSFW4kbSMt27XbuH_-v5aF?alt=media -o $outputFolder/NHTI.zip
curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1NxPV2a5WA0n9GXMO8ZD4B_2LEeLYrjGY?alt=media -o $outputFolder/Hookset.zip