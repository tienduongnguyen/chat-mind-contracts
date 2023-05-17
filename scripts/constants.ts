export const CONFIG_PATH = "./config/config.json";

export type ContractJson = {
    contractName: string;
    abi: any[];
    bytecode: string;
    deployedBytecode: string;
}

export type Config = {
    address: string;
    contractJson: ContractJson;
}