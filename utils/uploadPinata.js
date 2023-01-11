const fs=require('fs');
const path=require('path');
const pinataSDK = require('@pinata/sdk');
require('dotenv').config()
const pinata = new pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_API_SECRET);

async function storeImageinIPFS(imagepath)
{
    console.log('inside storeimage fnction')
    const fullImagePath=path.resolve(imagepath)
    const files=fs.readdirSync(fullImagePath).filter((file) => file.includes(".png"))
    let responses=[];
    for (i in files)
    {
        const readableFileStream= fs.createReadStream(`${fullImagePath}/${files[i]}`)
        // console.log(readableFileStream);
        const options = {
            pinataMetadata: {
                name: files[i].replace(".png", ""),
            },
        }
        try{
            const res = await pinata.pinFileToIPFS(readableFileStream,options);
            responses.push(res);
        }
        catch(e)
        {console.log(26,e)}
    }
    return {responses,files}
}
async function storeTokenUriMetadata(metadata) {
    const options = {
        pinataMetadata: {
            name: metadata.name,
        },
    }
    try {
        const response = await pinata.pinJSONToIPFS(metadata, options)
        return response
    } catch (error) {
        console.log("40",error)
    }
    return null
}
module.exports={storeImageinIPFS,storeTokenUriMetadata}