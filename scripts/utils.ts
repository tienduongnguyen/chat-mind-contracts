import { CONFIG_PATH, Config } from "./constants";
import fs from "fs";

function updateConfig(config: Config[]) {
    fs.writeFileSync(CONFIG_PATH, "{}");

    for (let i = 0; i < config.length; i++) {
        let file = fs.readFileSync(CONFIG_PATH);
        let json = JSON.parse(file.toString());
        const contractName = config[i].contractJson.contractName;
        json[contractName] = {
            contractName,
            address: config[i].address,
            abi: config[i].contractJson.abi,
            bytecode: config[i].contractJson.bytecode,
            deployedBytecode: config[i].contractJson.deployedBytecode,
        };
        fs.writeFileSync(CONFIG_PATH, JSON.stringify(json));
    }
}

export { updateConfig };
