// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/// @title ITrap Interface
/// @notice This interface defines the functions that a trap contract must implement.
/// @dev (Deprecated) Use Trap.sol instead.
interface ITrap {
    /// @notice Collect function to gather data from the trap for a block.
    /// @dev This function is expected to be implemented by the contract inheriting this interface.
    function collect() external view returns (bytes memory);

    /// @notice Determines if the trap should respond based on the provided data.
    /// @dev This function evaluates the provided data and returns a boolean indicating if a response is needed. The data is arranged where the first element in the array is the most recent data, and the last element is the oldest.
    /// @param data The abi encoded data to evaluate.
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
