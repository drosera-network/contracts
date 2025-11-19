// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EventLog, EventFilter, EventFilterLib} from "./libraries/Events.sol";

abstract contract Trap {
    EventLog[][] private eventLogs;

    /// @notice Collects data from the trap.
    /// @return The collected data as a bytes array.
    /// @dev This function is intended to be overridden by derived contracts to implement specific data collection logic.
    function collect() external view virtual returns (bytes memory);

    /// @notice Determines if an on-chain response should be made based on the provided data.
    /// @param data The data to evaluate for a response.
    /// @return A tuple containing a boolean indicating whether to respond and the response data as bytes.
    /// @dev This function is intended to be overridden by derived contracts to implement specific response logic
    function shouldRespond(bytes[] calldata data) external pure virtual returns (bool, bytes memory) {
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
        return "3.0";
    }

    /// @notice Batch-update the collected event logs for all filters
    /// @param logs A 2D array where logs[i] contains the new events for filter i
    /// @dev This function is intended to be used by the off-chain operator node to set the event logs for the trap.
    function setEventLogs(EventLog[][] calldata logs) external {
        EventFilter[] memory filters = eventLogFilters();
        require(logs.length == filters.length, "Logs length != filters length");

        // Ensure outer array is exactly the right size
        while (eventLogs.length < filters.length) {
            eventLogs.push(); // adds a new empty inner array
        }

        for (uint256 i = 0; i < filters.length;) {
            EventLog[] storage bucket = eventLogs[i];

            // Append the new batch for this filter
            EventLog[] calldata newBatch = logs[i];
            uint256 len = newBatch.length;

            for (uint256 j = 0; j < len;) {
                bucket.push(newBatch[j]);
                unchecked {
                    ++j;
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Retrieves the event logs stored in the trap.
    /// @return logs matrix of EventLog objects containing the stored event logs.
    /// @dev This function returns a copy of the event log matrix stored in the trap. It does not modify the state of the contract.
    /// @dev The logs are returned in the same order as the filters were provided to the setEventLogs function.
    function getEventLogs() public view returns (EventLog[][] memory logs) {
        uint256 filterCount = eventLogFilters().length;
        logs = new EventLog[][](filterCount);

        uint256 actualLogsCount = eventLogs.length;

        for (uint256 i = 0; i < filterCount;) {
            if (i < actualLogsCount) {
                EventLog[] storage storedLogs = eventLogs[i];
                EventLog[] memory copy = new EventLog[](storedLogs.length);

                for (uint256 j = 0; j < storedLogs.length;) {
                    copy[j] = storedLogs[j];
                    unchecked {
                        ++j;
                    }
                }
                logs[i] = copy;
            }

            unchecked {
                ++i;
            }
        }
    }
}
