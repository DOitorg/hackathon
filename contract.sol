// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentContract {
    mapping(address => uint256) private investments;
    address payable[] private validUsers;
    uint256 public totalInvestmentAmount;
    uint256 public totalInvestedUserCount;
    uint256 public charges;
    uint256 public adminBalance;
    address payable public admin;

    modifier onlyValidUser() {
        require(
            investments[msg.sender] == 0,
            "User is not allowed to reinvest."
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function.");
        _;
    }

    constructor() {
        admin = payable(msg.sender);
        charges = 0.1 ether;
    }

    receive() external payable {}

    // working
    function invest() external payable onlyValidUser returns (bool) {
        require(msg.sender != admin, "Admin not allowed");
        require(msg.value > charges, "Amount should be greater than 0.1 ETH");

        uint256 investedAmount = msg.value - charges;
        investments[msg.sender] = investedAmount;
        validUsers.push(payable(msg.sender));
        totalInvestmentAmount += investedAmount;
        totalInvestedUserCount++;

        // Transfer charges to admin's wallet
        
        adminBalance += charges;
        admin.transfer(charges);

        return true;
    }

    function removeUser() external returns (bool) {
        require(investments[msg.sender] > 0, "User has no investment.");

        for (uint256 i = 0; i < validUsers.length; i++) {
            if (validUsers[i] == payable(msg.sender)) {
                validUsers[i] = admin;
                return true;
            }
        }
        // if user is not found in validUsers array, return false
        return false;
        
    }

    function getValidUsersCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < validUsers.length; i++) {
            if (validUsers[i] != admin) {
                count++;
            }
        }
        return count;
    }

    //working
    function distributeFunds() external onlyAdmin returns (bool) {
        // check if there are any valid users
        uint256 validUsersCount = 0;
        for (uint256 i = 0; i < validUsers.length; i++) {
            if (validUsers[i] != admin) {
                validUsersCount++;
            }
        }
        // if no valid users, return false
        if (validUsersCount == 0) {
            return false;
        }

        uint256 amountPerUser = totalInvestmentAmount / validUsersCount;

        for (uint256 i = 0; i < validUsers.length; i++) {
            // if user is not admin, send the amount
            if (validUsers[i] != admin) {
                address payable user = validUsers[i];
                user.transfer(amountPerUser);
            }
        }
        return true;
    }

    function getTotalInvestment() external view returns (uint256) {
        return totalInvestmentAmount;
    }

    function getMyInvestment() external view returns (uint256) {
        return investments[msg.sender];
    }

    function getTotalUserCount() external view returns (uint256) {
        return totalInvestedUserCount;
    }

    

    function getInvalidUsersCount() external view returns (uint256) {
        // finding actual Invalid users
        uint256 count = 0;
        for (uint256 i = 0; i < validUsers.length; i++) {
            if (validUsers[i] == admin) {
                count++;
            }
        }
        return count;
    }

    function getAdminBalance() external view returns (uint256) {
        return adminBalance;
    }

    // function getMyProfit() external view returns (uint256) {

    //     uint256 validUserCount = 0;
    //     for (uint256 i = 0; i < validUsers.length; i++) {
    //         if (validUsers[i] != admin) {
    //             validUserCount++;
    //         }
    //     }

    //     if(validUserCount == 0) {
    //         return 0;
    //     }

    //     // check if user is in the validUsers array and return the InvestMent+Profit
    //     for (uint256 i = 0; i < validUsers.length; i++) {
    //         if (validUsers[i] == payable(msg.sender)) {
    //             unit256 profit = (totalInvestmentAmount / validUserCount) - investments[msg.sender];
    //             if(profit < 0) {
    //                 return profit*(-1);
    //             }
    //         }
    //     }
    //     return 0;
    // }

    function isUserValid() external view returns (bool) {
        // Find the user in validUsers array and return true if found
        for (uint256 i = 0; i < validUsers.length; i++) {
            if (validUsers[i] == payable(msg.sender)) {
                return true;
            }
        }
        return false;
    }
}