#!/bin/bash

AUTHTOKEN=ya29.a0ARrdaM9PH-nVTW6bmpq3MNl2aDgnR7x57xYQ0ug-1Gz9RplE1c3gnyjSlZywgkngVER4yaXfSoM6lqjFGOdws0iBntSI_ruAKrpmj2mdj2rvXTuPSnl_Xy3_gtTYhL1I7O7vyocki879JYIZ8RXE8fNHwJmO
outputFolder=E:/lecospec/

# download files from Google Drive automatically:
#curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1feK8G_r1B0fjxkOPB2zoM14qRIlBd461?alt=media -o $outputFolder/raw_2000_rd_rf_or
#curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1SI8OsOBGZrJKFVJfP-MtbGPKAVRPBV1y?alt=media -o $outputFolder/raw_2000_rd_rf_or.hdr
#curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1lo-uBH4wAXCSFW4kbSMt27XbuH_-v5aF?alt=media -o $outputFolder/NHTI.zip
curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1NyVhxyo9cKT3r2ZZ32ILYbD2t3eqtrTS?alt=media -o $outputFolder/raw_0_rd_rf_or
curl -H "Authorization: Bearer $AUTHTOKEN" https://www.googleapis.com/drive/v3/files/1av3R3ULUnXjOcz9wwoghivD8RSX9s6CH?alt=media -o $outputFolder/raw_0_rd_rf_or.hdr