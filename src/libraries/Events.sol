// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct EventLog {
    // The topics of the log, including the signature, if any.
    bytes32[] topics;
    // The raw data of the log.
    bytes data;
    // The address of the log's emitter.
    address emitter;
}

struct EventFilter {
    // The address of the contract to filter logs from.
    address contractAddress;
    // The topics to filter logs by.
    string signature;
}

/// @title Events Library
/// @notice A library for handling event logs and filters in smart contracts.
/// @dev This library provides functionality to create event filters, check if logs match filters, and compute topics for events.
library EventFilterLib {

    /// @notice Creates a topic0 from the given EventFilter.
    /// @param filter The EventFilter to create the topic0 from.
    /// @return The computed topic0 as a bytes32 value.
    /// @dev This function computes the first topic of the event filter by hashing the signature.
    function topic0(EventFilter memory filter) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(filter.signature));
    }

    /// @notice Checks if a log matches the given filter.
    /// @param filter The EventFilter to match against.
    /// @param log The EventLog to check.
    /// @return True if the log matches the filter's contract address and topic0, false otherwise.
    /// @dev This function checks if the log's emitter matches the filter's contract address and if the first topic of the log matches the filter's hash signature.
    function matches(
        EventFilter memory filter,
        EventLog memory log
    ) internal pure returns (bool) {
        // Check if the log's emitter matches the filter's contract address
        if (log.emitter != filter.contractAddress) {
            return false;
        }

        // Check if the first topic of the log matches the filter's topic0
        if (log.topics.length == 0 || log.topics[0] != topic0(filter)) {
            return false;
        }

        return true;
    }

    /// @notice Checks if a log matches the given filter's signature and has a zero contract address.
    /// @param filter The EventFilter to match against.
    /// @param log The EventLog to check.
    /// @return True if the log matches the filter's signature and has a zero contract address, false otherwise.
    function matches_signature(
        EventFilter memory filter,
        EventLog memory log
    ) internal pure returns (bool) {
        // Check if the signature matches and the contract address is zero
        return topic0(filter) == log.topics[0] && 
               filter.contractAddress == address(0);
    }
}
