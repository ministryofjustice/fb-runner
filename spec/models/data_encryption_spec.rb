RSpec.describe DataEncryption do
  subject(:data_encryption) do
    described_class.new(key:)
  end

  let(:data) { 'foo' }
  let(:key) { 'qwertyqwertyqwertyqwertyqwertyqw' }

  context 'when encrypting and decrypting the payload' do
    it 'encrypts the payload' do
      expect(data_encryption.encrypt(data)).to eq('acYk')
    end

    it 'decrypts the encrypted payload' do
      expect(data_encryption.decrypt('acYk')).to eq('foo')
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

  context 'when strict_decode64 fails' do
    it 'should attempt standard decode64' do
      encrypted_data = Base64.encode64(data)

      expect(Base64).to receive(:decode64).with(encrypted_data).and_return('foo')
      data_encryption.decrypt(encrypted_data)
    end
  end
end
