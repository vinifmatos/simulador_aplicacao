# frozen_string_literal: true

require_relative "simulador_aplicacao/version"
require "net/http"
require "uri"
require "json"
require "optparse"

module SimuladorAplicacao
  URL_API_BACEN = {
    cdi: "https://api.bcb.gov.br/dados/serie/bcdata.sgs.4392/dados/ultimos/1?formato=json",
    selic: "https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados/ultimos/1?formato=json",
    ipca: "https://api.bcb.gov.br/dados/serie/bcdata.sgs.13522/dados/ultimos/1?formato=json"
  }.freeze

  def self.simulacao(aporte_inicial, periodo, indice, aporte_mensal, resgate_mensal, inicio_resgate)
    taxa_anual = obter_taxa_anual_atualizada(indice)
    taxa_juros_mensal = taxa_anual_para_mensal(taxa_anual)
    total_acumulado = aporte_inicial
    total_investido = aporte_inicial
    rendimento_acumulado = 0
    rendimento_a_tributar = 0
    imposto_renda_pago = 0
    puts "Simulando com #{indice.to_s.upcase} #{format("%.2f", taxa_anual * 100)}% a.a"
    resultado_mensal = [
      {
        mes: 0,
        inicial: total_acumulado,
        taxa: "#{taxa_juros_mensal * 100}% a.m",
        rendimento_bruto: 0.0,
        aliquota_imposto_renda: 0.0,
        imposto_renda: 0.0,
        rendimento_liquido: 0.0,
        aporte: 0.0,
        resgate: 0.0,
        total_investido: total_investido,
        resultado: 0.0,
        acumulado: total_acumulado
      }
    ]
    (1..periodo).each do |mes|
      incial = total_acumulado
      rendimento = incial * taxa_juros_mensal
      rendimento_acumulado += rendimento
      total_acumulado += rendimento
      rendimento_a_tributar += rendimento
      if mes >= inicio_resgate
        imposto_renda = rendimento_a_tributar * aliquota_ir(mes)
        resgate = resgate_mensal
        total_acumulado -= (resgate + imposto_renda)
        imposto_renda_pago += imposto_renda
        rendimento_a_tributar = 0
      else
        imposto_renda = 0.0
        resgate = 0.0
      end
      total_acumulado += aporte_mensal
      total_investido += aporte_mensal
      resultado_mensal << {
        mes: mes,
        inicial: total_acumulado,
        taxa: "#{taxa_juros_mensal * 100}% a.m",
        rendimento_bruto: rendimento,
        aliquota_imposto_renda: aliquota_ir(mes),
        imposto_renda: imposto_renda,
        rendimento_liquido: rendimento - imposto_renda,
        aporte: aporte_mensal,
        resgate: resgate,
        total_investido: total_investido,
        resultado: rendimento - imposto_renda - resgate + aporte_mensal,
        acumulado: total_acumulado
      }
    end
    resultado_mensal
  end

  def self.aliquota_ir(mes)
    case
    when mes < 3 then 22.5
    when mes < 12 then 20
    when mes < 24 then 17.5
    else 15
    end / 100.0
  end

  def self.taxa_anual_para_mensal(taxa_anual)
    ((1.0 + taxa_anual)**(1.0 / 12.0) - 1.0).round(4)
  end

  def self.obter_taxa_anual_atualizada(indice)
    puts "Obtendo #{indice.to_s.upcase} atual..."
    taxa = JSON.parse(Net::HTTP.get(URI.parse(URL_API_BACEN[indice]))).first.fetch("valor").to_f
    puts "Concluído"
    taxa / 100.0
  rescue StandardError => e
    puts "Erro ao consultar a API"
    puts e
    exit
  end
end
