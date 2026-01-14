puts "================================================"
puts "Testando envio de email de reset de senha"
puts "================================================"
puts ""

if ENV["RESEND_API_KEY"].blank?
  puts "❌ ERRO: RESEND_API_KEY não está configurado no arquivo .env"
  puts ""
  puts "Configure a chave seguindo as instruções em docs/RESEND_SETUP.md"
  exit 1
end

puts "✅ RESEND_API_KEY configurado"
puts ""

user = User.first

unless user
  puts "❌ ERRO: Nenhum usuário encontrado no banco de dados"
  puts ""
  puts "Crie um usuário primeiro acessando: http://localhost:3000/users/sign_up"
  exit 1
end

puts "✅ Usuário encontrado: #{user.email}"
puts ""

begin
  puts "📧 Enviando email de reset de senha para #{user.email}..."

  token = user.send(:set_reset_password_token)

  UserMailer.reset_password_instructions(user, token).deliver_now

  puts ""
  puts "✅ Email enviado com sucesso!"
  puts ""
  puts "Verifique:"
  puts "1. O inbox de #{user.email}"
  puts "2. A pasta de spam"
  puts "3. O dashboard do Resend: https://resend.com/emails"
  puts ""
rescue => e
  puts ""
  puts "❌ ERRO ao enviar email:"
  puts e.message
  puts ""
  puts "Verifique:"
  puts "1. Se o RESEND_API_KEY está correto"
  puts "2. Se o servidor Rails foi reiniciado após configurar a chave"
  puts "3. Os logs em log/development.log"
  exit 1
end

puts "================================================"
