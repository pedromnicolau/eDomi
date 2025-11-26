# Seeds para criar imóveis de exemplo com dados realistas (Brasil).
# Idempotente: usa find_or_create_by por título.

puts "==> Criando usuário agente padrão..."
agent = User.find_or_create_by!(email: "agente.demo@edomi.test") do |u|
  u.password = "senha123456"
  u.name = "Agente Demo"
  u.role = :agent
end
agent.update(role: :agent) unless agent.agent?

properties_data = [
  {
    title: "Casa térrea ampla em Santos",
    description: "Casa térrea arejada, próximo à praia e ao comércio local. Quintal grande e edícula nos fundos.",
    price: 1250000.00,
    property_type: :house,
    area: 280.0,
    bedrooms: 4,
    bathrooms: 3,
    parking_spaces: 3,
    furnished: false,
    condominium_fee: 0,
    iptu: 450.75,
    year_built: 1998,
    address_attributes: {
      address_line1: "Rua Goiás, 145",
      neighborhood: "Gonzaga",
      city: "Santos",
      state: "SP",
      zip_code: "11055-201"
    }
  },
  {
    title: "Apartamento vista mar - Copacabana",
    description: "Apartamento no 12º andar com varanda e vista panorâmica para o mar. Reformado recentemente.",
    price: 1850000.00,
    property_type: :apartment,
    area: 110.0,
    bedrooms: 3,
    bathrooms: 2,
    parking_spaces: 1,
    furnished: true,
    condominium_fee: 1250.00,
    iptu: 390.20,
    year_built: 1985,
    address_attributes: {
      address_line1: "Av. Atlântica, 3020 Apt 1203",
      neighborhood: "Copacabana",
      city: "Rio de Janeiro",
      state: "RJ",
      zip_code: "22070-000"
    }
  },
  {
    title: "Terreno comercial na Marginal",
    description: "Terreno plano ideal para galpão ou centro logístico com fácil acesso à Marginal Tietê.",
    price: 3200000.00,
    property_type: :commercial,
    area: 1500.0,
    bedrooms: 0,
    bathrooms: 0,
    parking_spaces: 10,
    furnished: false,
    condominium_fee: 0,
    iptu: 2100.00,
    year_built: nil,
    address_attributes: {
      address_line1: "Rua João Teodoro, 500",
      neighborhood: "Brás",
      city: "São Paulo",
      state: "SP",
      zip_code: "03007-000"
    }
  },
  {
    title: "Loft moderno no Centro",
    description: "Loft integrado com pé-direito alto, iluminação natural e acabamento industrial.",
    price: 740000.00,
    property_type: :apartment,
    area: 68.0,
    bedrooms: 1,
    bathrooms: 1,
    parking_spaces: 1,
    furnished: true,
    condominium_fee: 650.00,
    iptu: 180.00,
    year_built: 2016,
    address_attributes: {
      address_line1: "Rua Sete de Setembro, 220",
      neighborhood: "Centro",
      city: "Curitiba",
      state: "PR",
      zip_code: "80060-120"
    }
  },
  {
    title: "Cobertura duplex com piscina",
    description: "Cobertura duplex com área gourmet, piscina privativa e vista livre.",
    price: 2350000.00,
    property_type: :apartment,
    area: 215.0,
    bedrooms: 4,
    bathrooms: 5,
    parking_spaces: 3,
    furnished: false,
    condominium_fee: 1800.00,
    iptu: 950.00,
    year_built: 2008,
    address_attributes: {
      address_line1: "Rua das Palmeiras, 880",
      neighborhood: "Vila Mariana",
      city: "São Paulo",
      state: "SP",
      zip_code: "04112-020"
    }
  },
  {
    title: "Chácara aconchegante em Atibaia",
    description: "Chácara com área verde, pomar formado e casa de hóspedes.",
    price: 980000.00,
    property_type: :house,
    area: 1200.0,
    bedrooms: 3,
    bathrooms: 3,
    parking_spaces: 6,
    furnished: false,
    condominium_fee: 0,
    iptu: 300.00,
    year_built: 2002,
    address_attributes: {
      address_line1: "Estrada da Usina, Km 4",
      neighborhood: "Zona Rural",
      city: "Atibaia",
      state: "SP",
      zip_code: "12940-000"
    }
  },
  {
    title: "Sala comercial mobiliada",
    description: "Sala pronta para escritório, ar-condicionado e cabeamento estruturado.",
    price: 360000.00,
    property_type: :commercial,
    area: 42.0,
    bedrooms: 0,
    bathrooms: 1,
    parking_spaces: 1,
    furnished: true,
    condominium_fee: 420.00,
    iptu: 120.00,
    year_built: 2019,
    address_attributes: {
      address_line1: "Av. Paulista, 1500 Conj. 712",
      neighborhood: "Bela Vista",
      city: "São Paulo",
      state: "SP",
      zip_code: "01310-200"
    }
  },
  {
    title: "Terreno amplo para loteamento",
    description: "Terreno amplo em zona de expansão urbana, ideal para pequeno loteamento residencial.",
    price: 4500000.00,
    property_type: :land,
    area: 8000.0,
    bedrooms: 0,
    bathrooms: 0,
    parking_spaces: 0,
    furnished: false,
    condominium_fee: 0,
    iptu: 5000.00,
    year_built: nil,
    address_attributes: {
      address_line1: "Rodovia SP-095, Km 12",
      neighborhood: "Área de Expansão",
      city: "Bragança Paulista",
      state: "SP",
      zip_code: "12900-000"
    }
  },
  {
    title: "Casa geminada próxima ao metrô",
    description: "Casa geminada reformada, a 5 minutos a pé da estação de metrô.",
    price: 690000.00,
    property_type: :house,
    area: 96.0,
    bedrooms: 2,
    bathrooms: 2,
    parking_spaces: 1,
    furnished: false,
    condominium_fee: 0,
    iptu: 165.00,
    year_built: 1995,
    address_attributes: {
      address_line1: "Rua Itapiru, 220",
      neighborhood: "Azenha",
      city: "Porto Alegre",
      state: "RS",
      zip_code: "90050-380"
    }
  },
  {
    title: "Studio funcional para investimento",
    description: "Studio em condomínio com lavanderia compartilhada e espaço coworking.",
    price: 310000.00,
    property_type: :apartment,
    area: 32.0,
    bedrooms: 1,
    bathrooms: 1,
    parking_spaces: 0,
    furnished: false,
    condominium_fee: 380.00,
    iptu: 90.00,
    year_built: 2023,
    address_attributes: {
      address_line1: "Rua Padre Chagas, 75 Apt 307",
      neighborhood: "Moinhos de Vento",
      city: "Porto Alegre",
      state: "RS",
      zip_code: "90570-080"
    }
  }
]

puts "==> Criando imóveis de exemplo..."
properties_data.each do |attrs|
  title = attrs[:title]
  existing = Property.find_by(title: title)
  if existing
    puts "• Já existe: #{title} (id=#{existing.id})"
    next
  end
  prop = Property.new(attrs.merge(agent_id: agent.id, status: :available))
  if prop.save
    puts "✓ Criado: #{prop.title} (id=#{prop.id})"
  else
    puts "✗ Erro ao criar #{title}: #{prop.errors.full_messages.join(', ')}"
  end
end

puts "==> Total de imóveis: #{Property.count}"
