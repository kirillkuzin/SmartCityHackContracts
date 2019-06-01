pragma solidity ^0.5.9;

contract Registry {
    struct Certificate {
        address owner;
        string generating_object;
        uint16 energy_type;
        uint256 amount_of_energy;
        uint256 time_of_start_of_production_period;
        uint256 time_of_stop_of_production_period;
        uint256 time_of_destruction;
        bool veryfied;
        bool redeemed;
    }
    mapping(uint256 => Certificate) certificates;
    uint256 public last_certificate_id;
    address public verification_agent;

    modifier check_verification_agent() {
        require(
            msg.sender == verification_agent,
            "The sender must be a verification agent."
        );
        _;
    }

    modifier check_certificate_owner(uint256 certificate_id) {
        require(
            msg.sender == certificates[certificate_id].owner,
            "The sender must be the owner of the certificate."
        );
        _;
    }

    modifier check_certificate_valid(uint256 certificate_id) {
        require(
            certificates[certificate_id].veryfied,
            "The certificate must be veryfied."
        );
        require(
            !certificates[certificate_id].redeemed,
            "The certificate must be not redeemed."
        );
        require(
            now < certificates[certificate_id].time_of_destruction,
            "The certificate burned out."
        );
        _;
    }

    function create_certificate(
        address owner,
        string calldata generating_object,
        uint16 energy_type,
        uint256 amount_of_energy,
        uint256 time_of_start_of_production_period,
        uint256 time_of_stop_of_production_period,
        uint256 time_of_destruction
    )
        external
        check_verification_agent
        returns (uint256)
    {
        Certificate memory certificate;
        certificate.owner = owner;
        certificate.generating_object = generating_object;
        certificate.energy_type = energy_type;
        certificate.amount_of_energy = amount_of_energy;
        certificate.time_of_start_of_production_period = time_of_start_of_production_period;
        certificate.time_of_stop_of_production_period = time_of_stop_of_production_period;
        certificate.time_of_destruction = time_of_destruction;
        certificates[last_certificate_id] = certificate;
        last_certificate_id++;
        return last_certificate_id - 1;
    }

    function redeem_certificate(
        uint256 certificate_id
    )
        external
        check_certificate_owner(certificate_id)
        check_certificate_valid(certificate_id)
    {
        certificates[certificate_id].redeemed = true;
    }

    function set_verification_agent_address(
        address new_verification_agent
    )
        external
        check_verification_agent
    {
        verification_agent = new_verification_agent;
    }

    constructor(address new_verification_agent) public {
         verification_agent = new_verification_agent;
    }

    function get_certificate(uint256 certificate_id)
        public
        view
        returns (
            address,
            string memory,
            uint16,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        Certificate memory certificate = certificates[certificate_id];
        return (
            certificate.owner,
            certificate.generating_object,
            certificate.energy_type,
            certificate.amount_of_energy,
            certificate.time_of_start_of_production_period,
            certificate.time_of_stop_of_production_period,
            certificate.time_of_destruction,
            certificate.veryfied,
            certificate.redeemed
        );
    }

}
