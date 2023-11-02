import { ethers, provider, signer } from "./ethers.js";
import { abi } from "./abi.js";

const coursetroContract = async () => {
  const address = "0x7C28047D36ef8D73A0e0d43077581133e66344FD";
  const contract = new ethers.Contract(address, abi, provider);
  const props = await contract.getInstructor();
  console.log(contract);
  console.log(props[0]);
  console.log(props[1].toString());
  $("#instructor").html(props[0] + " (" + props[1] + " years old)");

  const contractWithWallet = contract.connect(signer);

  $("#button").click(async () => {
    const tx = await contractWithWallet.setInstructor(
      $("#name").val(),
      $("#age").val()
    );
    console.log(tx);
  });

  contract.on("Update", (user, fname, age, event) => {
    let info = {
      user: user,
      fname: fname,
      age: age,
      event: event,
    };
    console.log(info);
    console.log(user);
    console.log(fname);
    console.log(age.toString());
  });
};

export { coursetroContract };
