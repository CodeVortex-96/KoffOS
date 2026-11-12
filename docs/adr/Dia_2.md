KoffOS — Atualização de desenvolvimento
Data: 12/11/2026
Versão de referência: v0.1
Ambiente de teste: QEMU
Objetivo deste registro: deixar o estado do kernel documentado para retomar o trabalho na próxima sessão.
1. Estado atual
O KoffOS v0.1 já consegue inicializar no QEMU e produzir saída pela porta serial COM1.

O projeto ainda está em uma fase inicial de bring-up do kernel. A inicialização serial funciona como primeiro canal de diagnóstico; o subsistema de vídeo/display está em desenvolvimento e ainda não deve ser tratado como um driver gráfico completo.

A arquitetura registrada no projeto é a de um kernel monolítico modular, para x86_64, com KOF como linguagem principal do kernel e uma inicialização própria apoiada pelo Limine neste estágio.
2. O que já foi feito
- [x] Estrutura inicial do projeto organizada em diretórios de boot, kernel, drivers, linker e documentação.
- [x] Configuração de boot do Limine criada.
- [x] Entry point x86_64 (boot/x86_64/entry.asm) implementado.
- [x] Stack inicial reservada no entry point.
- [x] Inicialização da comunicação serial COM1 implementada.
- [x] Rotinas de escrita e leitura serial separadas em arquivos Assembly.
- [x] Fluxo de entrada chama a inicialização serial, imprime a mensagem de boot e transfere o controle para kof_main.
- [x] Wrapper em Assembly criado para integrar o payload KOF.
- [x] Stub em C criado para símbolos e funções ainda necessários durante a integração freestanding.
- [x] Linker script x86_64 criado, com organização das seções e endereço higher-half.
- [x] Makefile preparado para compilar o kernel e gerar a imagem ISO.
- [x] ISO gerada e inicializada no QEMU.
- [x] Primeiros trabalhos do Display Engine iniciados; há uma rotina experimental de preparação de informações de framebuffer no entry point.
3. Arquivos relevantes
Arquivo	Responsabilidade
boot/x86_64/entry.asm	Entry point, stack inicial, chamada da serial e transferência para kof_main.
boot/x86_64/limine.cfg	Configuração de boot do Limine.
kernel/drivers/serial.asm	Inicialização e transmissão pela COM1.
kernel/drivers/serial_read.asm	Leitura pela porta serial.
kernel/core/kof_wrapper.asm	Integração do payload KOF com o kernel.
kernel/core/main.kf	Ponto de entrada do código KOF.
kernel/core/stubs.c	Implementações provisórias de símbolos/funções ainda não disponíveis no ambiente freestanding.
linker/x86_64.ld	Layout de memória e seções do executável do kernel.
makefile	Compilação, linkedição e geração da ISO.
docs/adr/0001-kernel-architecture.md	Registro da decisão arquitetural inicial.


4. Próxima sessão — plano de trabalho
A prioridade é consolidar a fundação do kernel antes de ampliar os subsistemas.
Etapa 1 — Conferir o estado reproduzível do boot
- [ ] Fazer um build limpo e gerar novamente a ISO.
- [ ] Inicializar a ISO no QEMU.
- [ ] Confirmar a saída serial e identificar claramente até onde a execução chega.
- [ ] Verificar se o caminho de execução realmente chega ao kof_main esperado, sem depender acidentalmente de um stub.
Etapa 2 — Fechar o contrato de boot e framebuffer
- [ ] Conferir a estrutura de dados de framebuffer recebida do Limine e seus offsets reais.
- [ ] Definir formalmente a estrutura interna usada pelo Display Engine.
- [ ] Separar a descoberta/validação do framebuffer da lógica de desenho.
- [ ] Só anunciar o Display Engine como inicializado quando a inicialização estiver efetivamente concluída.
Etapa 3 — Estabelecer as bases de CPU
- [ ] Definir e implementar a GDT.
- [ ] Implementar a IDT.
- [ ] Criar stubs de exceção e interrupção.
- [ ] Adicionar tratamento mínimo para exceções de CPU, com diagnóstico pela serial.
- [ ] Validar as rotinas de interrupção antes de habilitar interrupções de hardware.
Etapa 4 — Planejar a gestão de memória
- [ ] Mapear as informações de memória fornecidas pelo bootloader.
- [ ] Definir o modelo inicial de gestão de memória física.
- [ ] Implementar e testar o alocador físico de páginas.
- [ ] Depois, estruturar a gestão de memória virtual e o heap do kernel.
5. Pontos que precisam ser revisitados
Estes itens ficam registrados como verificações técnicas, não como afirmações de que já estejam causando falhas:
- [ ] Integração KOF/C: conferir quais símbolos são fornecidos pelo compilador KOF, pelo wrapper Assembly e pelo stub em C. Garantir que exista uma única implementação efetiva de cada ponto de entrada.
- [ ] Build: conferir as dependências entre kof_compile, os objetos gerados e a etapa de linkedição, especialmente em builds paralelos.
- [ ] Falhas de compilação: revisar o tratamento de erro da etapa KOF para que uma falha de compilação não seja silenciosamente ignorada.
- [ ] Framebuffer: validar a estrutura recebida e os offsets antes de usar a rotina experimental de cálculo de pitch.
- [ ] Mensagem de boot: ajustar a mensagem serial conforme os subsistemas realmente inicializados.
6. Critério de conclusão da próxima sessão
A próxima sessão será considerada produtiva se terminar com:
1. Um build reproduzível da ISO.
2. Boot confirmado no QEMU.
3. Fluxo de execução até o ponto de entrada KOF identificado.
4. Contrato de framebuffer documentado e validado — ou, se isso consumir a sessão, uma lista objetiva do que falta para validá-lo.
5. Uma decisão clara sobre a ordem de implementação de GDT, IDT e tratamento de exceções.
7. Observação para retomada
Não é necessário implementar todos os subsistemas de uma vez. A ideia é avançar por camadas, mantendo cada etapa testável e preservando a saída serial como ferramenta de diagnóstico enquanto o restante da infraestrutura ainda está sendo construído.
