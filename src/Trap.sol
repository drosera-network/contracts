// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EventLog, EventFilter, EventFilterLib} from "./libraries/Events.sol";

abstract contract Trap {
    EventLog[] private eventLogs;

    /// @notice Collects data from the trap.
    /// @return The collected data as a bytes array.
    /// @dev This function is intended to be overridden by derived contracts to implement specific data collection logic.
    function collect() external view virtual returns (bytes memory);

    /// @notice Determines if an on-chain response should be made based on the provided data.
    /// @param data The data to evaluate for a response.
    /// @return A tuple containing a boolean indicating whether to respond and the response data as bytes.
    /// @dev This function is intended to be overridden by derived contracts to implement specific response logic
    function shouldRespond(
        bytes[] calldata data
    ) external pure virtual returns (bool, bytes memory) {
        return (false, abi.encode("No response"));
    }


    /// @notice Determines if an alert should be made based on the provided data.
    /// @param data The data to evaluate for an alert.
    /// @return A tuple containing a boolean indicating whether to alert and the alert data as bytes.
    /// @dev This function is intended to be overridden by derived contracts to implement specific alert logic
    function shouldAlert(bytes[] calldata data) external pure virtual returns (bool, bytes memory) {
        return (false, abi.encode("No alert"));
    }


    /// @notice Returns the event filters for the trap.
    /// @return An array of EventFilter objects.
    /// @dev This function is intended to be overridden by derived contracts to provide specific event filters
    /// that the trap should listen to. The default implementation returns an empty array.
    /// @dev The filters can be used to match against event logs emitted by other contracts.
    function eventLogFilters() public view virtual returns (EventFilter[] memory) {
        EventFilter[] memory filters = new EventFilter[](0);
        return filters;
    }

    /// @notice Returns the version of the Trap.
    /// @return The version as a string.
    function version() public pure returns (string memory) {
        return "2.1";
    }

    /// @notice Sets the event logs in the trap.
    /// @param logs An array of EventLog objects to set.
    /// @dev This function should not be called. This function is designated to be used by the off-chain operator node.
    function setEventLogs(EventLog[] calldata logs) public {
       EventLog[] storage storageArray = eventLogs;
      
        // Set new logs
        for (uint256 i = 0; i < logs.length; i++) {
            storageArray.push(EventLog({
                emitter: logs[i].emitter,
                topics: logs[i].topics,
                data: logs[i].data
            }));
        }
    }

    /// @notice Retrieves the event logs stored in the trap.
    /// @return An array of EventLog objects containing the stored event logs.
    /// @dev This function returns a copy of the event logs stored in the trap. It does not modify the state of the contract.
    /// The logs can be used to analyze events emitted by other contracts that match the filters defined in `eventLogFilters`.
    /// @dev It is intended to be called in the `collect` function to gather event logs for further processing.
    function getEventLogs() public view returns (EventLog[] memory) {
        EventLog[] storage storageArray = eventLogs;
        EventLog[] memory logs = new EventLog[](storageArray.length);

        for (uint256 i = 0; i < storageArray.length; i++) {
            logs[i] = EventLog({
                emitter: storageArray[i].emitter,
                topics: storageArray[i].topics,
                data: storageArray[i].data
            });
        }
        return logs;
    }
}
