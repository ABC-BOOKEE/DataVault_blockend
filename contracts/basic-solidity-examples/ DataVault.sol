// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract DataVault {
    /*STATE VARIABLES */

    address private i_owner;
    event ReturnContrctId(address from_sender, address contractId);
    event returnLoginStatus(bool status, address opadd);

    /*WHAT THE CONTRACT IS MEANT TO PERFORM*/

    //creating the struct to add all the OPERATORS in the system
    //Be able to map the documents and operators address
    // struct for all documents added in the system
    // provide prreveledge with respect to _type
    // verify documents against the hash value
    // mapp the document with respect to the sender
    //map document with respect to the receiver
    //return all the user
    //adding the operators
    //validate the operators

    /*listing and adding the organisation*/
    struct Organisations {
        string orgName;
        address orgAddress;
        string[] members;
        string officeLocation;
    }
    Organisations[] organisationArray;

    /*mapping the address to organisation */
    mapping(address => Organisations) public organisationAvaailable;

    function isAvailable(address orgadd) public view returns (bool) {
        bool result = false;
        for (uint i; i < organisationArray.length; i++) {
            if (organisationArray[i].orgAddress == orgadd) {
                result = true;
                break;
            }
        }
        return result;
    }

    /* struct for operators*/

    struct Operators {
        address _userAdd;
        string[] documents;
    }

    /*create array of type operators*/

    Operators[] private operatorsArray;

    /* struct of documents/ currently */
    struct Document {
        string cidValue;
        address sender;
        string docName;
        string time;
        string size;
    }
    struct Users {
        address userAddres;
        string userType;
    }
    Users[] userArray;

    struct Shares {
        address sender;
        address receiver;
        string time;
    }

    struct docShares {
        string cidValue;
        Shares[] share;
    }

    /* creating array of documents */
    Document[] public documentArray;

    /* map the contracts and address */
    mapping(address => Operators) operators;
    mapping(string => docShares) DocumentShares;
    mapping(string => Document) documentMapping;
    mapping(address => Users) public usersMapping;

    /* constructor to initialize the value to stay forever*/
    constructor() {
        i_owner = msg.sender;

        usersMapping[i_owner].userType = "admin";
    }

    /*method adding the institution*/
    function addOrganisation(
        string memory name,
        address orgAdd,
        string memory location
    ) public ownerOnly {
        Organisations memory newOrg = Organisations({
            orgName: name,
            orgAddress: orgAdd,
            members: new string[](0),
            officeLocation: location
        });
        organisationArray.push(newOrg);

        Users memory newUser = Users({userAddres: orgAdd, userType: "institution"});

        userArray.push(newUser);
        usersMapping[orgAdd].userType = "institution";
    }

    /*retrievuing the organisation from the blockchain*/

    /*mapping the address to organisation */

    function testingAddress(address orgadd) public view returns (Organisations memory) {
        Organisations memory foundOrg;

        for (uint i; i < organisationArray.length; i++) {
            if (organisationArray[i].orgAddress == orgadd) {
                foundOrg = organisationArray[i];
            }
        }
        return foundOrg;
    }

    function getOrganisation() public view returns (Organisations[] memory) {
        return organisationArray;
    }

    /* method to add operators */
    function addOperators(
        // string memory name,
        // string memory org,
        address _userId
    ) public //  RegisteredInst
    {
        Operators memory newOperator = Operators({_userAdd: _userId, documents: new string[](0)});

        operatorsArray.push(newOperator);
        Users memory newUser = Users({userAddres: _userId, userType: "operator"});

        userArray.push(newUser);
        usersMapping[_userId].userType = "operator";
        // storeMembers.push(position);
    }

    /*view operators*/
    /*opr is supposed to be in the array*/
    function getOperators() public pure returns (Operators memory) {
        Operators memory opr;
        return opr;
    }

    /* verify operators on login */

    function operatorLogin(address add) public view returns (string memory) {
        return usersMapping[add].userType;
    }

    /* verify operators on login  */

    function operatorFinder(address add) public view returns (Operators memory) {
        Operators memory val;

        for (uint256 i = 0; i < operatorsArray.length; i += 1) {
            if (add == operatorsArray[i]._userAdd) {
                val = operatorsArray[i];
            }
        }
        return val;
    }

    function getAllOperators() public view returns (Operators[] memory) {
        return operatorsArray;
    }

    /* send the document by specify the the receiver address */
    // passing the address of the receiver

    function sendDocument(
        address _receiver,
        string memory _cidValue,
        string memory _time,
        string memory _size,
        string memory _docName
    ) public returns (bool) {
        operators[_receiver].documents.push(_cidValue);
        DocumentShares[_cidValue].cidValue = _cidValue;
        DocumentShares[_cidValue].share.push(Shares(msg.sender, _receiver, _time));

        /* adding the document to the it's array if it's not available yet */
        // bool isAvail = presenceChecker(hashedDocument);
        // if (!isAvail) {

        Document memory newdocument = Document({
            cidValue: _cidValue,
            sender: msg.sender,
            time: _time,
            docName: _docName,
            size: _size
        });

        documentArray.push(newdocument);
        return true;
    }

    // receive the document
    function receivedDocs() public view returns (Document[] memory) {
        uint256 arrayLength = documentArray.length;
        Document[] memory foundDocArray = new Document[](arrayLength);

        string[] memory doc = operators[msg.sender].documents;
        for (uint i; i < doc.length; i++) {
            for (uint j; j < documentArray.length; j++) {
                if (keccak256(bytes(documentArray[j].cidValue)) == keccak256(bytes(doc[i]))) {
                    foundDocArray[j] = documentArray[j];
                }
            }
        }

        return foundDocArray;
    }

    /*storing documents*/
    function store(
        string memory _cidValue,
        string memory _time,
        string memory _docName,
        string memory _size
    ) public {
        /* adding the document to the it's array if it's not available yet */
        Document memory newdocument = Document({
            cidValue: _cidValue,
            sender: msg.sender,
            docName: _docName,
            time: _time,
            size: _size
        });
        documentArray.push(newdocument);
    }

    /* verifying document */
    mapping(string => Document) public foundDoc;

    function verifyDocument(string memory _cid) public view returns (bool) {
        bool val;
        for (uint i; i < documentArray.length; i++) {
            if (keccak256(bytes(documentArray[i].cidValue)) == keccak256(bytes(_cid))) {
                val = true;
            } else {
                val = false;
            }
        }
        return val;
    }

    /*MODIFIERS */
    modifier ownerOnly() {
        require(msg.sender == i_owner, "you aren't owner");
        _;
    }

    modifier RegisteredUser() {
        for (uint256 i = 0; i < operatorsArray.length; i += 1) {
            if (msg.sender == operatorsArray[i]._userAdd) {
                _;
            }
        }
    }

    modifier RegisteredInst() {
        for (uint256 i = 0; i < organisationArray.length; i += 1) {
            if (msg.sender == organisationArray[i].orgAddress) {
                _;
            }
        }
    }

    /* INDIRECT METHODS 

/* Testing function to retrieving operators */
    function getOperatorss(uint256 index) public view returns (Operators memory) {
        return operatorsArray[index];
    }

    /*testing function to view the documents in the addresses */
    function getDocuments(address oppadd) public view returns (Document[] memory) {
        uint256 arrayLength = documentArray.length;
        Document[] memory foundDocument = new Document[](arrayLength);
        uint256 j;
        for (uint256 i; i < documentArray.length; i++) {
            if (documentArray[i].sender == oppadd) {
                foundDocument[j] = documentArray[i];
                j++;
            }
        }
        return foundDocument;
    }

    /*checking the documents in the document array*/
    function presenceChecker(string memory hashedDoc) public view returns (bool) {
        bool val;
        for (uint256 i; i < documentArray.length; i += 1) {
            //keccak256(bytes(a)) == keccak256(bytes(b)); = using this when comparing string literals

            if (keccak256(bytes(hashedDoc)) == keccak256(bytes(documentArray[i].cidValue))) {
                val = true;
            } else {
                val = false;
            }
        }

        return val;
    }

    /*checking the documents shares */
    function getShares(string memory _cidValue) public view returns (Shares[] memory) {
        Shares[] memory docShare = DocumentShares[_cidValue].share;
        return docShare;
    }
}
