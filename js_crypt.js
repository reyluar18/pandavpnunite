

//   function stringToBytes(str) {
//     const encoder = new TextEncoder();
//     return encoder.encode(str);
//   }
  

  

    // // Example usage
    // (async () => {
    //     const plaintext = "Hello, world!";
        
    //     const password = "panda_vpn_unite";
    //     const salt = crypto.getRandomValues(new Uint8Array(16)); // Generate a random salt
      
    //     const aesKey = await generateAESKeyFromPassword(password, salt);
    //     console.log("Generated AES Key:", aesKey);
        
    //     // Encrypt
    //     const encrypted = await encryptStringWithAES(plaintext, aesKey);
    //     console.log("Encrypted:", encrypted);
        
    //     // Decrypt
    //     const decrypted = await decryptStringWithAES(encrypted, aesKey);
    //     console.log("Decrypted:", decrypted);
    //   })();
      
    //     // Example usage
    //     const myString = "panda_vpn_unite";
    //     const byteArray = stringToBytes(myString);
    //     console.log("Byte Array:", byteArray);
      
        
    //     // Example usage
    //     const byteArray = new Uint8Array(  [
    //       112,97,110,100,97,95,118,112,110,95,117,110,105,116,101
    //    ]);
    //     const myString = bytesToString(byteArray);
    //     console.log("Decoded String:", myString); // "Hello, world!"
      
      



  /////////////

  async function generateAESKeyFromPassword(password, salt) {
    const encoder = new TextEncoder();
    const encodedPassword = encoder.encode(password);
    const encodedSalt = encoder.encode(salt);
  
    const keyMaterial = await crypto.subtle.importKey(
      "raw",
      encodedPassword,
      { name: "PBKDF2" },
      false,
      ["deriveKey"]
    );
  
    const key = await crypto.subtle.deriveKey(
      {
        name: "PBKDF2",
        salt: encodedSalt,
        iterations: 100000, // number of iterations (higher is better for security)
        hash: "SHA-256" // hash function to use
      },
      keyMaterial,
      { name: "AES-GCM", length: 256 }, // derived key's algorithm details
      true, // key can be used for encryption
      ["encrypt", "decrypt"]
    );
  
    return key;
  }

  
  // Function to encrypt a string with AES
  async function encryptStringWithAES(str, key) {
    const encodedStr = new TextEncoder().encode(str);
    const iv = crypto.getRandomValues(new Uint8Array(12)); // Initialization vector
  
    const encrypted = await crypto.subtle.encrypt(
      {
        name: "AES-GCM",
        iv: iv,
      },
      key,
      encodedStr
    );
  
    // Combine IV and encrypted data into a single array
    const encryptedArray = new Uint8Array(iv.byteLength + encrypted.byteLength);
    encryptedArray.set(new Uint8Array(iv), 0);
    encryptedArray.set(new Uint8Array(encrypted), iv.byteLength);
  
    // Convert to base64
    return btoa(String.fromCharCode(...encryptedArray));
  }
  
  // Function to decrypt a string with AES
  async function decryptStringWithAES(str, key) {
    const encryptedArray = new Uint8Array(atob(str).split('').map(char => char.charCodeAt(0)));
  
    // Extract IV from the beginning of the encrypted data
    const iv = encryptedArray.slice(0, 12);
    const encryptedData = encryptedArray.slice(12);
  
    const decrypted = await crypto.subtle.decrypt(
      {
        name: "AES-GCM",
        iv: iv,
      },
      key,
      encryptedData
    );
  
    return new TextDecoder().decode(decrypted);
  }
  
  (async () => {

  })();
  
  

  function bytesToString(bytes) {
    const decoder = new TextDecoder();
    return decoder.decode(bytes);
  }

  const byteArray = new Uint8Array(  [
    112,97,110,100,97,95,118,112,110,95,117,110,105,116,101
    ]);

  const execute = _ => {
    const password = bytesToString(byteArray);

    (async () => {
        const here = "59S5f7kh8PKCzsxJEAa+YraVT3SehCy1vdhBcm2c723ItUXOhG9muA8=";
        const salt = crypto.getRandomValues(new Uint8Array(16)); // Generate a random salt
        const aesKey = await generateAESKeyFromPassword(password, salt);
        const decrypted = await decryptStringWithAES(here, aesKey);
        console.log("Decrypted:", decrypted);
      })();
  }

  const eexecute = _ => {
    const password = bytesToString(byteArray);

    (async () => {
        const here = "Hello, world!";
        const salt = crypto.getRandomValues(new Uint8Array()); // Generate a random salt
        const aesKey = await generateAESKeyFromPassword(password, salt);
        const decrypted = await encryptStringWithAES(here, aesKey);
        console.log("Decrypted:", decrypted);

        const e = await decryptStringWithAES(decrypted, aesKey);
        console.log("Decrypted:", e);
      })();
  }




  

