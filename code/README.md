
# AWS Lambda: Gerenciamento de Serviços ECS com Tags

## Descrição
Essa função Lambda automatiza o gerenciamento de serviços ECS com base em tags associadas aos serviços. É possível iniciar, parar ou ajustar o número desejado de tarefas (`desiredCount`) dos serviços ECS em clusters especificados.

## Funcionalidades
- Identifica serviços ECS em clusters com base em uma tag e seu valor.
- Ajusta o número desejado de tarefas (`desiredCount`) para os serviços filtrados.
- Suporta as ações:
  - **start**: Inicia o serviço.
  - **stop**: Para o serviço.
- Monitora a implantação do serviço e notifica em caso de falhas.
- Publica mensagens de erro em um tópico SNS configurado.

## Parâmetros de Entrada
A função Lambda aceita os seguintes parâmetros no evento de entrada:

| Parâmetro       | Tipo   | Obrigatório | Descrição                                                                 |
|------------------|--------|-------------|---------------------------------------------------------------------------|
| `tag`           | String | Não         | Nome da tag usada para identificar os serviços. Valor padrão: `automation_ecs_stop_start`. |
| `tag_value`     | String | Sim         | Valor da tag usado para identificar os serviços que serão ajustados.      |
| `action`        | String | Sim         | Ação a ser executada: `start` (iniciar) ou `stop` (parar).                |
| `desired_count` | Int    | Não         | Número desejado de tarefas para serviços. Necessário apenas se `action` não for `start` ou `stop`. |

### Exemplo de Entrada
```json
{
    "tag": "automation_ecs_stop_start",
    "tag_value": "my-service-tag",
    "action": "start"
}
```

## Variáveis de Ambiente
- **`sns_alert`**: ARN do tópico SNS para envio de notificações em caso de falhas.

## Permissões Necessárias
A função Lambda deve ter permissões para:
- Listar clusters ECS.
- Listar serviços ECS.
- Atualizar serviços ECS.
- Publicar mensagens no tópico SNS.

Exemplo de política IAM mínima:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:ListClusters",
                "ecs:ListServices",
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "resourcegroupstaggingapi:GetResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME"
        }
    ]
}
```

## Funcionamento

### 1. Validação de Parâmetros
- Verifica se os parâmetros obrigatórios (`tag_value`, `action`) estão presentes.
- Valida o valor da ação (`start` ou `stop`).

### 2. Listagem de Clusters e Serviços
- Lista todos os clusters na conta AWS.
- Para cada cluster, lista os serviços associados.

### 3. Filtragem por Tag
- Verifica se os serviços possuem a tag e o valor especificados.
- Determina o `desiredCount` com base na ação:
  - **`stop`**: Define `desiredCount` como 0.
  - **`start`**: Define `desiredCount` como o valor de `default_desired_count` na tag (ou padrão de 1).

### 4. Atualização do Serviço
- Atualiza o `desiredCount` do serviço ECS.
- Inicia o monitoramento da implantação.

### 5. Monitoramento da Implantação
- Verifica o progresso da implantação até que o estado seja `COMPLETED` ou ocorra timeout.

### 6. Notificação de Erros
- Em caso de erro, envia uma mensagem para o tópico SNS configurado.

## Saídas

### Sucesso
```json
{
    "status": "success",
    "message": "Serviços atualizados com sucesso."
}
```

### Erro
```json
{
    "status": "error",
    "message": "Descrição detalhada do erro ocorrido."
}
```

## Estrutura de Código
O código é composto pelas seguintes funções principais:

1. **`lambda_handler(event, context)`**:
   - Função principal chamada pelo AWS Lambda.

2. **`publish_to_sns(error_message)`**:
   - Publica mensagens de erro no tópico SNS.

3. **`ecs_update_desiredCount(cluster_name, service_name, desiredCount)`**:
   - Atualiza o número desejado de tarefas (`desiredCount`) de um serviço ECS.

4. **`get_latest_deployment_id(cluster_name, service_name)`**:
   - Obtém o ID da implantação mais recente para um serviço.

5. **`monitor_deployment(cluster_name, service_name, deployment_id, timeout=600, interval=15)`**:
   - Monitora o progresso da implantação.

## Exemplo de Execução
### Entrada:
```json
{
    "tag": "automation_ecs_stop_start",
    "tag_value": "my-service-tag",
    "action": "start"
}
```

### Saída:
```json
{
    "status": "success",
    "message": "Serviço iniciado com sucesso."
}
```

## Licença
Este projeto está licenciado sob a [MIT License](LICENSE).
