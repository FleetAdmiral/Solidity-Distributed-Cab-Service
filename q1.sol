pragma solidity ^0.4.14;

import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract Ballot
{
    using strings for *;

    struct request {
        string pick_loc;
        string drop_loc;
        bool accepted;
        string reqid;
        uint256 create_time;
        address cust_address;
    }

    struct customer {
        string name;
    }

    struct driver {
        string name;
        int256 rating;
        string number_plate;
    }

    mapping (address => customer) customers;
    mapping (address => driver) cab_drivers;
    mapping (int256 => request) requests;
    mapping (int256 => string) bets;
    mapping (int256 => int256) num_bets;
    mapping (int256 => string) num_to_words;
    address[] driver_addresses;
    event RideGiven(int256 rideId, string driver_add);

    function Ballot()
    {
        num_to_words[int256(1)] = "1";
        num_to_words[int256(2)] = "2";
        num_to_words[int256(3)] = "3";
        num_to_words[int256(4)] = "4";
        num_to_words[int256(5)] = "5";
        num_to_words[int256(6)] = "6";
    }

    customer c1;
    driver d1;


    function RegisterCustomer(string name) public
    {
        c1.name = name;
        customers[msg.sender] = c1;
    }


    function RegisterDriver(string name, string number_plate) public
    {
        d1.name = name;
        d1.number_plate = number_plate;
        cab_drivers[msg.sender] = d1;
        driver_addresses.push(msg.sender);
    }

    int256 requestid = 1;
    request r1;
    function RequestRide(string pickup, string drop) returns(int256)
    {
        if(keccak256(checkExistenceCustomer()) == keccak256("false"))
            return -1;
        r1.pick_loc = pickup;
        r1.drop_loc = drop;
        r1.accepted = false;
        r1.reqid = num_to_words[requestid];
        r1.cust_address = msg.sender;
        r1.create_time = now;
        requests[requestid] = r1;
        bets[requestid] = "";
        num_bets[requestid] = 0;
        requestid += 1;
        int256 temprequest = requestid - 1;
        return temprequest;
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function uintToString(uint256 v) private returns (string str)
    {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }


    function uint2str(uint i) internal pure returns (string)
    {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0)
        {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0)
        {
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function bytes32ToString (bytes32 data) private returns (string)
    {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++)
        {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0)
            {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }

    function addressToString(address x) private returns (string)
    {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }


    function seeRequests() public returns(string)
    {
        if(keccak256(checkExistenceDriver()) == keccak256("false"))
            return "Only drivers can see requests.";
        string memory output = "";
        for (int i=1;i<requestid;i++)
        {

            if (requests[i].accepted == false)
            {
                output = output.toSlice().concat((requests[i].reqid).toSlice());
                output = output.toSlice().concat("_".toSlice());
                output = output.toSlice().concat((requests[i].pick_loc).toSlice());
                output = output.toSlice().concat("_".toSlice());
                output = output.toSlice().concat((requests[i].drop_loc).toSlice());
                output = output.toSlice().concat("~".toSlice());
            }
        }
        return output;
    }


    function placeBet(int256 rideId, string name, string bet) public returns(string)
    {

        if(keccak256(checkExistenceDriver()) == keccak256("false"))
            return "Driver does not exist";
        if(keccak256(requests[rideId].cust_address) == keccak256(""))
            return "Request Id does not exist";
        if(requests[rideId].cust_address == msg.sender)
            return "You cannot bet on your own request";
        if(requests[rideId].accepted == true)
            return "Request has already been allotted.";
        if(now - requests[rideId].create_time > 100)
            return "Timeout to place bets";
        if(keccak256(cab_drivers[msg.sender].name) != keccak256(name))
            return "Name does not match";
        // if(stringToUint(bet) < uint(0))
        //     return "Bet has to be non-negative";

        // string memory address_str = addressToString(msg.sender);
        string memory output = "";
        output = output.toSlice().concat(bets[rideId].toSlice());
        output = output.toSlice().concat(name.toSlice());
        output = output.toSlice().concat(".".toSlice());
        output = output.toSlice().concat(bet.toSlice());
        output = output.toSlice().concat("~".toSlice());

        // strConcat(bets[rideId],address_str,".",uintToString(uint256(bet)),"~");
        bets[rideId] = output;
        num_bets[rideId] += 1;
        return output;

    }

    function checkExistenceCustomer() private returns(string)
    {
        if(keccak256(customers[msg.sender].name) == keccak256(""))
            return "false";
        return "true";
    }

    function checkExistenceDriver() private returns(string)
    {
        if(keccak256(cab_drivers[msg.sender].name) == keccak256(""))
            return "false";
        return "true";
    }

    function stringToUint(string s) constant returns (uint result)
    {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++)
        {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57)
            {
                result = result * 10 + (c - 48);
            }
        }
    }

    function update_min(uint256 fare) private returns(uint256 min)
    {
        min = fare;
        return min;
    }

    function getDrivertwo(string[] parts) private returns(string)
    {
        uint256 min = 100000;
        string memory min_driver;
        for (uint j=0;j<parts.length;j++)
        {
            var s2 = parts[j].toSlice();
            var delim2 = ".".toSlice();
            var split = new string[](s2.count(delim2) + 1);
            for(uint k = 0; k < split.length; k++)
            {
                split[k] = s2.split(delim2).toString();
            }
            uint fare = stringToUint(split[1]);
            if  (fare < min)
            {
                min = update_min(fare);
                min_driver = split[0];
                min_driver = min_driver.toSlice().concat("-".toSlice());
                min_driver = min_driver.toSlice().concat(split[1].toSlice());
            }
        }
        return min_driver;
    }

    function getDriver(int256 requestId) returns(string)
    {

        if(keccak256(requests[requestId].cust_address) == keccak256(""))
            return "No such request exists";
        if(keccak256(bets[requestId]) == keccak256(""))
            return "No bets for this ride";
        if(keccak256(checkExistenceCustomer()) == keccak256("false"))
            return "Only customers can get drivers.";
        if(requests[requestId].cust_address != msg.sender)
            return "This is not your request";

        var s = bets[requestId].toSlice();
        var delim = "~".toSlice();
        var parts = new string[](s.count(delim));
        for(uint i = 0; i < parts.length; i++)
        {
            parts[i] = s.split(delim).toString();
        }
        string memory to_return = getDrivertwo(parts);
        RideGiven(requestId, to_return);
        requests[requestId].accepted = true;
        return to_return;
    }


}
