// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityDonation {
    address public charity;
    uint256 public targetAmount;
    uint256 public currentAmount;
    uint256 public status;

    struct Donation {
        address donor;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(uint256 => Donation[]) public donations;
    mapping(uint256 => string) public projectNames;

    event ProjectCreated(uint256 projectId, string name, uint256 targetAmount);
    event DonationMade(uint256 projectId, address donor, uint256 amount, uint256 timestamp);

    constructor() {
        charity = msg.sender;
    }

    modifier onlyCharity() {
        require(msg.sender == charity, "Only charity can call this function");
        _;
    }

    function createProject(uint256 projectId, string memory name, uint256 _targetAmount) external onlyCharity {
        require(bytes(projectNames[projectId]).length == 0, "Project with given ID already exists");
        projectNames[projectId] = name;
        targetAmount = _targetAmount;
        emit ProjectCreated(projectId, name, _targetAmount);
    }

    function donate(uint256 projectId) external payable {
        require(bytes(projectNames[projectId]).length > 0, "Project with given ID does not exist");
        require(msg.value > 0, "Donation amount should be greater than zero");

        donations[projectId].push(Donation(msg.sender, msg.value, block.timestamp));
        currentAmount += msg.value;

        emit DonationMade(projectId, msg.sender, msg.value, block.timestamp);

        if (currentAmount >= targetAmount) {
            status = 1;
        }
    }

    function getDonations(uint256 projectId) external view returns (Donation[] memory) {
        return donations[projectId];
    }

    function getProjectName(uint256 projectId) external view returns (string memory) {
        return projectNames[projectId];
    }

    // Receive function to receive Ether
    receive() external payable {
        // Optional: You can add custom logic here if needed
    }
}