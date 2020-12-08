RSpec.describe DataEncryption do
subject(:data_encryption) do
  described_class.new(key: key)
end

let(:data){'foo'}
let(:key) {'qwertyqwertyqwertyqwertyqwertyqw'}

  context 'when encrypting and decrypting the payload' do
    it 'encrypts the payload' do
      expect(data_encryption.encrypt(data)).to eq("acYk\n")
    end

    it 'decrypts the encrypted payload' do
      expect(data_encryption.decrypt("acYk\n")).to eq('foo')
    end
  end

  context 'when decrypting with the wrong key' do
    let(:another_data_encryption) do
      described_class.new(key: 'qwertyqwertyqwertyqwertyqwertyas')
    end

    it 'fails to decrypt' do
      encrypted_data = data_encryption.encrypt(data)
      expect(another_data_encryption.decrypt(encrypted_data)).to_not eq('foo')
    end
  end
end
