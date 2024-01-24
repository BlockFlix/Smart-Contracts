// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// Simple structure to represent a user
struct User {
    string fullName;
    string email;
    uint256 dateOfBirth;
    bool isRegistered;
}

// Main contract
contract BlockFlix is Ownable(msg.sender) {
    mapping(address => User) public users;
    mapping(uint256 => address) public movieOwners;
    mapping(uint256 => string) public movieIPFSHashes;

    event UserRegistered(address indexed userAddress, string fullName, string email, uint256 dateOfBirth);
    event MovieUploaded(address indexed owner, uint256 movieId, string ipfsHash);
    event MoviePurchased(address indexed buyer, address indexed seller, uint256 movieId);

    // Register a new user
    function registerUser(string memory _fullName, string memory _email, uint256 _dateOfBirth) external {
        require(!users[msg.sender].isRegistered, "User already registered");
        users[msg.sender] = User(_fullName, _email, _dateOfBirth, true);
        emit UserRegistered(msg.sender, _fullName, _email, _dateOfBirth);
    }

    // Get user details
    function getUserDetails() external view returns (string memory, string memory, uint256) {
        require(users[msg.sender].isRegistered, "User not registered");

        User memory currentUser = users[msg.sender];
        return (currentUser.fullName, currentUser.email, currentUser.dateOfBirth);
    }

    // Upload a movie to IPFS
    function uploadMovie(string memory _ipfsHash) external onlyOwner {
        uint256 movieId = uint256(keccak256(abi.encodePacked(_ipfsHash, block.timestamp)));
        movieOwners[movieId] = msg.sender;
        movieIPFSHashes[movieId] = _ipfsHash;
        emit MovieUploaded(msg.sender, movieId, _ipfsHash);
    }

    // Purchase a movie
    function purchaseMovie(uint256 _movieId) external payable {
        require(users[msg.sender].isRegistered, "User not registered");
        require(msg.value > 0, "Invalid payment amount");
        require(movieOwners[_movieId] != address(0), "Movie not found");
        address payable movieOwner = payable(movieOwners[_movieId]);
        movieOwner.transfer(msg.value);
        emit MoviePurchased(msg.sender, movieOwner, _movieId);
    }
}
