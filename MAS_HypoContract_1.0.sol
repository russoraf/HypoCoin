//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HypoCoin {


// Contract-Owner definitions
    
    address private _owner;
    enum State {Created, InReview, Verified, Rejected} State public status; 

    constructor() {
	    _owner = msg.sender;
    }


// Mapping User Registration Approvals & Regisrations

    mapping(address => User) private users;
    mapping(address => uint) private VendorRegistration;
    mapping(address => uint) private BuyerRegistration;
    mapping(address => uint) private InvestorRegistration;
    mapping(address => uint) private NotaryRegistration;

// User Struct (for Approval)    
    struct User{
      State status;        
    }


// RealEstate Struct

struct RealEstate {
        string ImmoName;
        uint ParcelId;
        string street;
        string city;
        uint price;
        address OwnerAddress;
        address NotaryAddress;
        address ReservationAddress;
		bool paymentBuyer;
		bool paymentInvestor;
    }
    RealEstate[] public realestates;



// Functions ContractOwner

    function owner() public view returns(address) {
        return _owner;
    }
    
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }


    function UserRegistrationApproval(address user) public onlyOwner{
        users[user].status = State.Verified;
    }

// Modifiers for Restricted Access

    modifier onlyOwner(){
	    require(isOwner(),"Function accessible only by the owner!!");
	    _;
    }

    modifier onlyVendors {
        require(users[msg.sender].status == State.Verified, "You have not been verified yet!.");
        _;
    }

    modifier onlyBuyers {
        require(users[msg.sender].status == State.Verified, "You have not been verified yet!.");
        _;
    }

    modifier onlyInvestors {
        require(users[msg.sender].status == State.Verified, "You have not been verified yet!.");
        _;
    }

    modifier onlyNotary {
        require(users[msg.sender].status == State.Verified, "You have not been verified yet!.");
        _;
    }


// Join-Function (Registration without Verification) 

    function joinAsVendor() public {
        VendorRegistration[msg.sender] = block.number;
        users[msg.sender].status = State.InReview;
    }
    
    function joinAsBuyer() public {
        BuyerRegistration[msg.sender] = block.number;
        users[msg.sender].status = State.InReview;
    }

    function joinAsInvestor() public {
        InvestorRegistration[msg.sender] = block.number;
        users[msg.sender].status = State.InReview;
    }

    function joinAsNotary() public {
        NotaryRegistration[msg.sender] = block.number;
        users[msg.sender].status = State.InReview;
    }


// Functions with restricted access (Can be used after User-Verification)

    function CreateRealEstate(
        string memory _ImmoName,
        uint _ParcelId,
        string memory _street,
        string memory _city,
        uint _price,
        address _NotaryAddress
        )
        public onlyVendors{
            realestates.push(RealEstate(
				_ImmoName, 
				_ParcelId, 
				_street, 
				_city, 
				_price, 
				address(msg.sender), 
				_NotaryAddress, 
				address(0), 
				bool(false), 
				bool(false)
				)
			);
      }


      function MakeReservation(address payable _to, uint _ind) external payable onlyBuyers{
        (bool success, ) = _to.call{value: msg.value} ("");
        require(success, "Payment failed");
        RealEstate storage todo = realestates[_ind];
        todo.ReservationAddress = msg.sender;
    }

   
    function Deposit20(address payable _to, uint _REindex) external payable onlyBuyers{
        (bool success, ) = _to.call{value: msg.value} ("");
        require(success, "Deposit failed");
		RealEstate storage todo = realestates[_REindex];
		todo.paymentBuyer = true;

    }

    function Deposit80(address payable _to, uint _indexRE) external payable onlyInvestors{
        (bool success, ) = _to.call{value: msg.value} ("");
        require(success, "Payment failed");
		RealEstate storage todo = realestates[_indexRE];
		todo.paymentInvestor = true;
    }

    function CompleteBusiness(address payable _to, uint _index, address _OwnerAddress) external payable onlyNotary{
        (bool success, ) = _to.call{value: msg.value} ("");
        require(success, "Payment failed");
        RealEstate storage todo = realestates[_index];
        todo.OwnerAddress = _OwnerAddress;
    }

}
